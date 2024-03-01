require "rails_helper"

RSpec.describe SyncCustomerSubscriptionJob, type: :job, vcr: true do

  before do
    Sidekiq::Testing.inline!
  end

  context "perform" do
    it "fails if it cannot find the company" do
      expect { SyncCustomerSubscriptionJob.perform_async(0) }.to raise_error { ActiveRecord::RecordNotFound }
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
        ]},
        {proration_date: Date.today.iso8601}
      )

      SyncCustomerSubscriptionJob.perform_inline(company.id)
    end
  end
end