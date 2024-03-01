module Stripe
  class CustomerUpdated
    def initialize(customer)
      @customer = customer
    end

    def call
      # update the customer's default payment method, email, name, etc.
      company = Company.find_by(stripe_id: @customer.id)

      if company.blank?
        # Rollbar.report_message("Customer not found for Stripe ID: #{@customer.id}", 'warning')
        return
      end

      updates = {
        customer_email: @customer.email,
        customer_name: @customer.name,
      }

      if @customer.invoice_settings.default_payment_method.present?
        payment_method = Stripe::PaymentMethod.retrieve(@customer.invoice_settings.default_payment_method)
        updates = updates.merge(
          default_payment_method: @customer.invoice_settings.default_payment_method,
          payment_method_type: payment_method.type
        )

        case payment_method.type
        when "card"
          updates = updates.merge(
            payment_metadata: {
              credit_card_brand: payment_method.card.brand,
              credit_card_last_four: payment_method.card.last4,
              credit_card_exp_month: payment_method.card.exp_month,
              credit_card_exp_year: payment_method.card.exp_year
            }
          )
        when "link"
          updates = updates.merge(
            payment_metadata: {
              email: payment_method.link.email
            }
          )
        end
      end

      company.subscription.update(updates)
    end
  end
end