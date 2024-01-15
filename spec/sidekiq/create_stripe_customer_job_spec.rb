require "rails_helper"

RSpec.describe CreateStripeCustomerJob, type: :job, vcr: true do
  before do
    Sidekiq::Testing.inline!
  end

  context "when the user is not signed in" do
    it "fails if it cannot find the company" do
      expect { CreateStripeCustomerJob.perform_inline(1) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "fails if it cannot find the owner" do
      company = create(:company)
      expect { CreateStripeCustomerJob.perform_inline(company.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "creates a stripe customer" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      user = registration.user
      expect(Company.count).to eq(1)
      company = Company.first

      customer = Stripe::Customer.retrieve(company.stripe_id)
      expect(customer.email).to eq(user.email)
    end
  end
end