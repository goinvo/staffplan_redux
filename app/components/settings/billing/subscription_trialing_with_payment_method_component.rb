# frozen_string_literal: true

module Settings
  module Billing
    class SubscriptionTrialingWithPaymentMethodComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end

      delegate :subscription, to: :@company

      def subscription_percentage
        time_today = Time.now.at_beginning_of_day.to_i
        start_time = subscription.current_period_start.at_beginning_of_day.to_i
        end_time = subscription.current_period_end.at_beginning_of_day.to_i
        numerator = time_today - start_time
        denominator = end_time - start_time

        "#{((numerator.to_f / denominator) * 100).round}%"
      end

      delegate :credit_card_brand, to: :subscription

      delegate :credit_card_last_four, to: :subscription

      delegate :credit_card_exp_month, to: :subscription

      delegate :credit_card_exp_year, to: :subscription

      delegate :customer_name, to: :subscription

      delegate :customer_email, to: :subscription

      def subtotal
        amount = Money.new(subscription.plan_amount, 'USD') * subscription.quantity
        Money.new(amount, 'USD')
      end
    end
  end
end
