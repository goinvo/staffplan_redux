require 'rails_helper'

RSpec.describe User, type: :model do
  context "validations" do
    it "requires a current company" do
      user = build(:user)
      user.update(current_company: nil)
      expect(user).to_not be_valid
    end
    
    it "requires a unique email" do
      user = create(:membership).user
      other_user = build(:membership, user: build(:user, email: user.email)).user
      expect(other_user).to_not be_valid
    end

    it "requires a valid email" do
      user = build(:user, email: "invalid")
      expect(user).to_not be_valid
    end

    it "requires a name" do
      user = build(:user, name: nil)
      expect(user).to_not be_valid
    end
  end

  describe "#owner?" do
    it "is true when user is an owner" do
      user = create(:membership, role: Membership::OWNER).user
      expect(user.owner?(company: user.current_company)).to be_truthy
    end

    it "is false when user is not an owner" do
      user = create(:membership, role: Membership::MEMBER).user
      expect(user.owner?(company: user.current_company)).to be_falsey
    end
  end

  describe "#admin?" do
    it "is true when user is an admin" do
      user = create(:membership, role: Membership::ADMIN).user
      expect(user.admin?(company: user.current_company)).to be_truthy
    end

    it "is false when user is not an admin" do
      user = create(:membership, role: Membership::MEMBER).user
      expect(user.admin?(company: user.current_company)).to be_falsey
    end
  end

  describe "#role" do
    it "returns the user's role" do
      user = create(:membership, role: Membership::ADMIN).user
      expect(user.role(company: user.current_company)).to eq(Membership::ADMIN)
    end
  end

  describe "#inactive?" do
    it "is true when user is inactive" do
      user = create(:membership, status: Membership::INACTIVE).user
      expect(user.inactive?(company: user.current_company)).to be_truthy
    end

    it "is false when user is active" do
      user = create(:membership, status: Membership::ACTIVE).user
      expect(user.inactive?(company: user.current_company)).to be_falsey
    end
  end

  describe "#toggle_status!" do
    it "toggles the user's status from active to inactive" do
      user = create(:membership, status: Membership::ACTIVE).user
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(user.current_company.id)
      user.toggle_status!(company: user.current_company)
      expect(user.inactive?(company: user.current_company)).to be_truthy
    end

    it "toggles the user's status from inactive to active" do
      user = create(:membership, status: Membership::INACTIVE).user
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(user.current_company.id)
      user.toggle_status!(company: user.current_company)
      expect(user.inactive?(company: user.current_company)).to be_falsey
    end

    it "syncs the customer subscription" do
      user = create(:membership, status: Membership::ACTIVE).user
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(user.current_company.id)
      user.toggle_status!(company: user.current_company)
    end
  end
end
