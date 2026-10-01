# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :check_subscription_status

    def create
      endpoint_secret = Rails.application.credentials.stripe_signing_secret
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret,
        )
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        Rollbar.error(e)
        head :bad_request and return
      end

      case event.type
      when 'customer.subscription.updated'
        Stripe::SubscriptionUpdated.new(event.data.object).call
      when 'customer.subscription.created', 'customer.subscription.deleted'
        Stripe::SaveSubscription.new(event.data.object).call
      when 'customer.updated'
        Stripe::CustomerUpdated.new(event.data.object).call
      else
        Rails.logger.debug { "Unhandled event type: #{event.type}" }
      end

      head :ok
    end
  end
end
