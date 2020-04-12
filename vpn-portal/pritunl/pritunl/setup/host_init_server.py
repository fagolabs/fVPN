from pritunl import settings
from pritunl import subscription
from pritunl import logger
import sys

def setup_host_init_server():
    subscription.update()

    if settings.app.license and settings.app.license_plan != 'premium':
        return

    from pritunl import server
    host_id = settings.local.host_id

    for svr in server.iter_servers(fields=['hosts']):
        if svr.hosts == []:
            svr.hosts = [host_id]
            svr.commit('hosts')
