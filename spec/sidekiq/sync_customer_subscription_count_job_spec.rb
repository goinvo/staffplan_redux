require "rails_helper"

RSpec.describe SyncCustomerSubscriptionCountJob, type: :job, vcr: true do

  before do
    Sidekiq::Testing.inline!
  end

  context "perform" do
    it "fails if it cannot find the company" do
      expect { SyncCustomerSubscriptionCountJob.perform_async(0) }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it "fails if the company has no subscription" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      expect(Company.count).to eq(1)

      company = Company.first
      expect_any_instance_of(Company).to receive(:subscription).and_return(nil)
      expect_any_instance_of(Company).to_not receive(:memberships)

      SyncCustomerSubscriptionCountJob.perform_inline(company.id)
    end

    it "updates the subscription item quantity" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      expect(Company.count).to eq(1)

      company = Company.first

      # attach a test payment method
      method = Stripe::PaymentMethod.attach(
        "pm_card_visa",
        {customer: company.stripe_id}
      )

      # actually create the subscription
      Stripe::Subscription.create(
        {
          customer: company.stripe_id,
          items: [{price: Rails.application.credentials.stripe_price_id}],
          default_payment_method: method.id,
        }
      )

      expect(company.subscription.items.first.quantity).to eq(1)
      create(:membership, company: company)
      expect(company.memberships.active.count).to eq(2)

      SyncCustomerSubscriptionCountJob.perform_inline(company.id)
      expect(company.reload.subscription.items.first.quantity).to eq(2)
    end

    it "sends an email to the company's owners" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      expect(Company.count).to eq(1)

      company = Company.first

      # attach a test payment method
      method = Stripe::PaymentMethod.attach(
        "pm_card_visa",
        {customer: company.stripe_id}
      )

      # actually create the subscription
      Stripe::Subscription.create(
        {
          customer: company.stripe_id,
          items: [{price: Rails.application.credentials.stripe_price_id}],
          default_payment_method: method.id,
        }
      )

      # adds a new active user to company
      create(:membership, company: company)

      SyncCustomerSubscriptionCountJob.perform_inline(company.id)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq(company.owners.map(&:email))
      expect(ActionMailer::Base.deliveries.first.subject).to eq("StaffPlan Subscription Updated")
    end
  end
end