require "rails_helper"

RSpec.describe Stripe::SyncCustomerSubscriptionJob, type: :job, vcr: true do

  context "perform" do
    it "fails if it cannot find the company" do
      expect { Stripe::SyncCustomerSubscriptionJob.perform_now(Company.new) }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it "informs Stripe of the new quantity" do
      registration = create(:registration, email: "something@static.com")
      registration.register!
      expect(Company.count).to eq(1)

      company = Company.first

      expect(company.memberships.active.count).to eq(1)
      create(:membership, company: company)
      expect(company.memberships.active.count).to eq(2)

      expect(Stripe::Subscription).to receive(:update).with(
        company.subscription.stripe_id,
        { items: [
          {id: company.subscription.item_id,  quantity: 2 }
        ]}
      )

      Stripe::SyncCustomerSubscriptionJob.perform_now(company)
    end
  end
end
