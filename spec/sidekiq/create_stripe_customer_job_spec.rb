require "rails_helper"

RSpec.describe CreateStripeCustomerJob, type: :job, vcr: true do
  before do
    Sidekiq::Testing.inline!
  end

  context "perform" do
    it "fails if it cannot find the company" do
      expect { CreateStripeCustomerJob.perform_inline(1) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "creates a stripe customer" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      user = registration.reload.user
      expect(Company.count).to eq(1)
      company = Company.first

      customer = Stripe::Customer.retrieve(company.stripe_id)
      expect(customer.email).to eq(user.email)
    end

    it "save stripe_id to company" do
      registration = create(:registration, email: "something@static.com")
      registration.register!

      expect(Company.count).to eq(1)
      company = Company.first

      # this call would presumably fail if the stripe_id was not saved to the company
      customer = Stripe::Customer.retrieve(company.stripe_id)
      expect(customer.id).to eq(company.stripe_id)
    end

    describe "stripe subscription" do
      it "creates a subscription" do
        registration = create(:registration, email: "something@static.com")
        registration.register!

        expect(Company.count).to eq(1)
        company = Company.first

        expect(company.subscription).to be_present
      end

      it "saves without any credit card information (if on a free trial)" do
        registration = create(:registration, email: "something@static.com")
        registration.register!

        company = Company.first
        subscription = company.subscription
        expect(subscription.credit_card_brand).to be_nil
        expect(subscription.credit_card_last_four).to be_nil
        expect(subscription.credit_card_exp_month).to be_nil
        expect(subscription.credit_card_exp_year).to be_nil
      end

      it "stores stripe_price_id, customer_name, customer_email, plan_amount, and quantity" do
        registration = create(
          :registration,
          email: "something@static.com",
          name: "static name",
          company_name: "static company name"
        )
        registration.register!

        company = Company.first
        subscription = company.subscription
        expect(subscription.stripe_price_id).to eq(Rails.application.credentials.stripe_price_id)
        expect(subscription.customer_name).to eq("#{registration.company_name} | #{registration.name}")
        expect(subscription.customer_email).to eq(company.owners.first.email)
        expect(subscription.plan_amount).to eq(300)
      end
    end
  end
end