module Settings
  module Billing
    class SubscriptionDetailsComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end

      def subscription
        return @_subscription if defined?(@_subscription)

        @_subscription = @company.subscription
      end

      def subscription_percentage
        time_today = Time.now.at_beginning_of_day.to_i
        start_time = Time.at(subscription.current_period_start).at_beginning_of_day.to_i
        end_time = Time.at(subscription.current_period_end).at_beginning_of_day.to_i
        numerator =  time_today - start_time
        denominator = end_time - start_time

        "#{((numerator.to_f / denominator.to_f) * 100).round}%"
      end

      def payment_method
        return @_payment_method if defined?(@_payment_method)
        @_payment_method = Stripe::PaymentMethod.retrieve(subscription.default_payment_method)
      end

      def credit_card
        payment_method.card
      end

      def customer
        return @_customer if defined?(@_customer)

        @_customer = Stripe::Customer.retrieve(subscription.customer)
      end

      def subtotal
        amount = Money.new(subscription.plan.amount, "USD") * subscription.quantity
        Money.new(amount, "USD")
      end
    end
  end
end