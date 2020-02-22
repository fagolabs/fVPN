from pritunl.constants import *
from pritunl.helpers import *
from pritunl.exceptions import *
from pritunl import settings
from pritunl import logger
from pritunl import utils
from pritunl import event
from pritunl import mongo
from pritunl import messenger
import time
import math
import requests

def update():
    license = settings.app.license
    collection = mongo.get_collection('settings')

    if not settings.app.id:
        settings.app.id = utils.random_name()
        settings.commit()

    settings.local.sub_active = True
    settings.local.sub_status = 'active'
    settings.local.sub_plan = 'enterprise'
    settings.local.sub_quantity = 1
    settings.local.sub_amount = 2500
    settings.local.sub_period_end = math.floor(time.time()) + 2592000000
    settings.local.sub_trial_end = math.floor(time.time()) + 2592000000
    settings.local.sub_cancel_at_period_end = False
    settings.local.sub_balance = 0
    settings.local.sub_url_key = "url"
    settings.local.sub_styles['enterprise'] = {'etag':'1c253d-6c2-4e3a2f30b418d','last_modified':'Wed, 23 Oct 2019 07:52:54 GMT','data':'dark'}
    # if not license:
    #     settings.local.sub_active = False
    #     settings.local.sub_status = None
    #     settings.local.sub_plan = None
    #     settings.local.sub_quantity = None
    #     settings.local.sub_amount = None
    #     settings.local.sub_period_end = None
    #     settings.local.sub_trial_end = None
    #     settings.local.sub_cancel_at_period_end = None
    #     settings.local.sub_balance = None
    #     settings.local.sub_url_key = None
    # else:
        
        # for i in xrange(2):
            # try:
            #     # url = 'https://app.pritunl.com/subscription'
            #     # if settings.app.dedicated:
            #     #     url = settings.app.dedicated + '/subscription'

            #     # response = requests.get(
            #     #     url,
            #     #     json={
            #     #         'id': settings.app.id,
            #     #         'license': license,
            #     #         'version': settings.local.version_int,
            #     #     },
            #     #     timeout=max(settings.app.http_request_timeout, 10),
            #     # )

            #     # # License key invalid
            #     # if response.status_code == 470:
            #     #     raise ValueError('License key is invalid')

            #     # if response.status_code == 473:
            #     #     raise ValueError(('Version %r not recognized by ' +
            #     #         'subscription server') % settings.local.version_int)

            #     # data = response.json()

                
            #     # settings.local.sub_styles['enterprise'] = 'dark'
            # except:
            #     if i < 1:
            #         logger.exception('Failed to check subscription status',
            #             'subscription, retrying...')
            #         time.sleep(1)
            #         continue
            #     logger.exception('Failed to check subscription status',
            #         'subscription')
            #     settings.local.sub_active = True
            #     settings.local.sub_status = 'active'
            #     settings.local.sub_plan = 'enterprise'
            #     settings.local.sub_quantity = 1
            #     settings.local.sub_amount = 250
            #     settings.local.sub_period_end = math.floor(time.time()/1000) + 2592000
            #     settings.local.sub_trial_end = math.floor(time.time()/1000) + 2592000
            #     settings.local.sub_cancel_at_period_end = False
            #     settings.local.sub_balance = 0
            #     settings.local.sub_url_key = True
            #     # settings.local.sub_styles['enterprise'] = 'dark'
            # break
            

    if settings.app.license_plan != settings.local.sub_plan and \
            settings.local.sub_plan:
        settings.app.license_plan = settings.local.sub_plan
        settings.commit()

    response = collection.update({
        '_id': 'subscription',
        '$or': [
            {'active': {'$ne': settings.local.sub_active}},
            {'plan': {'$ne': settings.local.sub_plan}},
        ],
    }, {'$set': {
        'active': settings.local.sub_active,
        'plan': settings.local.sub_plan,
    }})
    if response['updatedExisting']:
        if settings.local.sub_active:
            if settings.local.sub_plan == 'premium':
                event.Event(type=SUBSCRIPTION_PREMIUM_ACTIVE)
            elif settings.local.sub_plan == 'enterprise':
                event.Event(type=SUBSCRIPTION_ENTERPRISE_ACTIVE)
            elif settings.local.sub_plan == 'enterprise_plus':
                event.Event(type=SUBSCRIPTION_ENTERPRISE_PLUS_ACTIVE)
            else:
                event.Event(type=SUBSCRIPTION_NONE_INACTIVE)
        else:
            if settings.local.sub_plan == 'premium':
                event.Event(type=SUBSCRIPTION_PREMIUM_INACTIVE)
            elif settings.local.sub_plan == 'enterprise':
                event.Event(type=SUBSCRIPTION_ENTERPRISE_INACTIVE)
            elif settings.local.sub_plan == 'enterprise_plus':
                event.Event(type=SUBSCRIPTION_ENTERPRISE_PLUS_INACTIVE)
            else:
                event.Event(type=SUBSCRIPTION_NONE_INACTIVE)

    return True

def dict():
    if settings.app.demo_mode:
        url_key = 'demo'
    else:
        url_key = settings.local.sub_url_key

    return {
        'active': settings.local.sub_active,
        'status': settings.local.sub_status,
        'plan': settings.local.sub_plan,
        'quantity': settings.local.sub_quantity,
        'amount': settings.local.sub_amount,
        'period_end': settings.local.sub_period_end,
        'trial_end': settings.local.sub_trial_end,
        'cancel_at_period_end': settings.local.sub_cancel_at_period_end,
        'balance': settings.local.sub_balance,
        'url_key': url_key,
    }

def update_license(license):
    settings.app.license = license
    settings.app.license_plan = None
    settings.commit()
    valid = update()
    messenger.publish('subscription', 'updated')
    if not valid:
        raise LicenseInvalid('License key is invalid')
