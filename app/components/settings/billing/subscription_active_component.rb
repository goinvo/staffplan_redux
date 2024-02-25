module Settings
  module Billing
    class SubscriptionActiveComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end

      def subscription
        @company.subscription
      end

      def subscription_percentage
        time_today = Time.now.at_beginning_of_day.to_i
        start_time = subscription.current_period_start.at_beginning_of_day.to_i
        end_time = subscription.current_period_end.at_beginning_of_day.to_i
        numerator =  time_today - start_time
        denominator = end_time - start_time

        "#{((numerator.to_f / denominator.to_f) * 100).round}%"
      end

      def credit_card_brand
        subscription.credit_card_brand
      end

      def credit_card_last_four
        subscription.credit_card_last_four
      end

      def credit_card_exp_month
        subscription.credit_card_exp_month
      end

      def credit_card_exp_year
        subscription.credit_card_exp_year
      end

      def customer_name
        subscription.customer_name
      end

      def customer_email
        subscription.customer_email
      end

      def subtotal
        amount = Money.new(subscription.plan_amount, "USD") * subscription.quantity
        Money.new(amount, "USD")
      end
    end
  end
end