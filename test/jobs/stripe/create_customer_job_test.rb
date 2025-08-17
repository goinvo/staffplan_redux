require "test_helper"

class Stripe::CreateCustomerJobTest < ActiveJob::TestCase

  describe "perform" do
    before do
      assert_equal 0, Company.count
    end

    it "fails if it cannot find the company" do
      assert_raises(ActiveRecord::RecordNotFound) do
        Stripe::CreateCustomerJob.perform_now(Company.new)
      end
    end

    it "creates a stripe customer" do
      VCR.use_cassette("stripe/create_customer_job/creates_a_stripe_customer") do
        registration = create(:registration, email: "something@static.com")
        registration.register!

        Stripe::CreateCustomerJob.perform_now(Company.first)

        user = registration.reload.user
        assert_equal 1, Company.count
        company = Company.first

        customer = Stripe::Customer.retrieve(company.stripe_id)
        assert_equal user.email, customer.email
      end
    end

    it "save stripe_id to company" do
      VCR.use_cassette("stripe/create_customer_job/save_stripe_id_to_company") do
        registration = create(:registration, email: "something@static.com")
        registration.register!

        Stripe::CreateCustomerJob.perform_now(Company.first)

        assert_equal 1, Company.count
        company = Company.first

        # this call would presumably fail if the stripe_id was not saved to the company
        customer = Stripe::Customer.retrieve(company.stripe_id)
        assert_equal company.stripe_id, customer.id
      end
    end

    describe "stripe subscription" do
      it "creates a subscription" do
        VCR.use_cassette("stripe/create_customer_job/stripe_subscription/creates_a_subscription") do
          registration = create(:registration, email: "something@static.com")
          registration.register!

          Stripe::CreateCustomerJob.perform_now(Company.first)

          assert_equal 1, Company.count
          company = Company.first

          assert company.subscription.present?
        end
      end

      it "saves without any credit card information (if on a free trial)" do
        VCR.use_cassette("stripe/create_customer_job/stripe_subscription/saves_without_any_credit_card_information_if_on_a_free_trial_") do
          registration = create(:registration, email: "something@static.com")
          registration.register!

          Stripe::CreateCustomerJob.perform_now(Company.first)

          company = Company.first
          subscription = company.subscription
          assert_nil subscription.credit_card_brand
          assert_nil subscription.credit_card_last_four
          assert_nil subscription.credit_card_exp_month
          assert_nil subscription.credit_card_exp_year
        end
      end

      it "stores stripe_price_id, the rest comes in via webhooks" do
        VCR.use_cassette("stripe/create_customer_job/stripe_subscription/stores_stripe_price_id_the_rest_comes_in_via_webhooks") do
          registration = create(
            :registration,
            email: "something@static.com",
            name: "static name",
            company_name: "static company name"
          )
          registration.register!

          Stripe::CreateCustomerJob.perform_now(Company.first)

          company = Company.first
          subscription = company.subscription
          assert subscription.stripe_id.present?
        end
      end
    end
  end
end