define([
  'jquery',
  'underscore',
  'backbone'
], function($, _, Backbone) {
  'use strict';
  var SubscriptionModel = Backbone.Model.extend({
    defaults: {
      'card': null,
      'email': null,
      'url_key': null,
      'active': true,
      'status': 'active',
      'plan': 'enterprise',
      'quantity': 1,
      'amount': 250,
      'period_end': Math.floor(new Date().getTime() / 1000) + 2592000,
      'trial_end': Math.floor(new Date().getTime() / 1000) + 2592000,
      'cancel_at_period_end': false,
      'balance': 0,
      'version': null,
      'theme': null,
      'super_user': true,
      'sso': 'google'
    },
    isNew: function() {
      var active = this.get('active');
      return active === null || active === undefined;
    },
    url: function() {
      return '/subscription';
    },
    parse: function(response) {
      this.unset('cancel');
      return response;
    },
    getStatusData: function() {
      var loadMsg;
      var completeMsg;
      var status = this.get('status');
      if (status === 'canceled') {
        loadMsg = 'Reactivating subscription, please wait...';
        completeMsg = 'Subscription successfully reactivated.';
        return ['Inactive', 'error-text', 'checkout_reactivate',
          loadMsg, completeMsg];
      }
      else if (this.get('cancel_at_period_end')) {
        loadMsg = 'Reactivating subscription, please wait...';
        completeMsg = 'Subscription successfully reactivated, you will '+
          'not be charged until the end of the current subscription period.';
        return ['Canceled', 'error-text', 'checkout_renew',
          loadMsg, completeMsg];
      }
      else if (status === 'past_due') {
        loadMsg = 'Reactivating subscription, please wait...';
        completeMsg = 'Subscription successfully reactivated.';
        return ['Past Due', 'warning-text', 'checkout_reactivate',
          loadMsg, completeMsg];
      }
      else {
        if (status === 'trialing') {
          status = 'Trial Period';
        }
        else {
          status = 'Active';
        }

        loadMsg = 'Updating payment information, please wait...';
        completeMsg = 'Payment information successfully updated, you will '+
          'not be charged until the end of the current subscription period.';
        return [status, 'success-text', 'checkout_update',
          loadMsg, completeMsg];
      }
    }
  });

  return SubscriptionModel;
});
