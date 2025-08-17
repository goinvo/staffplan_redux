require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  describe "validations" do
    it "requires a user" do
      membership = build(:membership, user: nil)
      refute membership.valid?
    end

    it "requires a company" do
      membership = build(:membership, company: nil)
      refute membership.valid?
    end

    it "requires a unique user scoped to company" do
      membership = create(:membership)
      other_membership = build(:membership, user: membership.user, company: membership.company)
      refute other_membership.valid?
    end

    it "requires a status" do
      membership = build(:membership, status: nil)
      refute membership.valid?
    end

    it "requires a valid status" do
      membership = build(:membership, status: "invalid")
      refute membership.valid?
    end

    it "requires a role" do
      membership = build(:membership, role: nil)
      refute membership.valid?
    end

    it "requires a valid role" do
      membership = build(:membership, role: "invalid")
      refute membership.valid?
    end
  end

  describe "#confirmed?" do
    it "returns true if status is active" do
      membership = build(:membership, status: "active")
      assert_equal true, membership.active?
    end

    it "returns false if status is not active" do
      membership = build(:membership, status: "inactive")
      assert_equal false, membership.active?
    end
  end
end