require 'rails_helper'

RSpec.describe Membership, type: :model do
  context "validations" do
    it "requires a user" do
      membership = build(:membership, user: nil)
      expect(membership).to_not be_valid
    end

    it "requires a company" do
      membership = build(:membership, company: nil)
      expect(membership).to_not be_valid
    end

    it "requires a unique user scoped to company" do
      membership = create(:membership)
      other_membership = build(:membership, user: membership.user, company: membership.company)
      expect(other_membership).to_not be_valid
    end

    it "requires a status" do
      membership = build(:membership, status: nil)
      expect(membership).to_not be_valid
    end

    it "requires a valid status" do
      membership = build(:membership, status: "invalid")
      expect(membership).to_not be_valid
    end

    it "requires a role" do
      membership = build(:membership, role: nil)
      expect(membership).to_not be_valid
    end

    it "requires a valid role" do
      membership = build(:membership, role: "invalid")
      expect(membership).to_not be_valid
    end
  end

  describe "#confirmed?" do
    it "returns true if status is active" do
      membership = build(:membership, status: "active")
      expect(membership.active?).to eq(true)
    end

    it "returns false if status is not active" do
      membership = build(:membership, status: "inactive")
      expect(membership.active?).to eq(false)
    end
  end
end
