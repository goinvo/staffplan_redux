# lib/tasks/stripe.rake
namespace :stripe do
  desc "creates necessary things for StaffPlan's stripe integration"
  task bootstrap: :environment do
    # Heads up! Stripe entity creation is done async, re-running this rake task in rapid succession may create
    # multiple products in your Stripe account. While this isn't a problem, it's a source of confusion.

    PRODUCT_NAME = "StaffPlan"

    # check for key
    if Rails.application.credentials.stripe_api_key.blank?
      puts "No Stripe API key found. Please add one to your credentials file using rails credentials:edit"
      exit
    end

    # create product
    product = Stripe::Product.search({query: "active:\"true\" AND name~'#{PRODUCT_NAME}'"})
    if product.data.empty?
      puts "...creating a new product"
      product = Stripe::Product.create({
        name: PRODUCT_NAME,
        default_price_data: {
          currency: "usd",
          unit_amount: 300,
          recurring: {
            interval: "month"
          }
        }
      })
    else
      puts "...found an existing product"
      product = product.data.first
    end

    # create portal
    portal = Stripe::BillingPortal::Configuration.list
    if portal.data.empty?
      portal = Stripe::BillingPortal::Configuration.create({
        business_profile: {
          privacy_policy_url: "https://example.com/privacy",
          terms_of_service_url: "https://example.com/tos"
        },
        features: {
          customer_update: {
            enabled: true,
            allowed_updates: ["name", "email", "address", "phone"]
          },
          invoice_history: {
            enabled: true
          },
          payment_method_update: {
            enabled: true
          },
          subscription_cancel: {
            enabled: true,
            cancellation_reason: {
              enabled: true,
              options: ["other", "too_expensive"]
            },
            mode: "at_period_end"
          }
        },
        login_page: {
          enabled: true
        },
        default_return_url: "http://localhost:3000"
      })
    else
      portal = portal.data.first
      puts "...found an existing billing portal configuration, assuming it's correct"
    end

    puts "\nStripe integration setup complete! Update your local credentials with the following values:\n\n"
    puts "stripe_price_id: #{product.default_price}"
    puts "stripe_customer_portal_url: #{portal.login_page.url}"
  end
end
