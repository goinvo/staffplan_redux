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
  end
end