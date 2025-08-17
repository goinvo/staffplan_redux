require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe "validations" do
    it "requires a current company" do
      user = build(:user)
      user.update(current_company: nil)
      refute user.valid?
    end
    
    it "requires a unique email" do
      user = create(:membership).user
      other_user = build(:membership, user: build(:user, email: user.email)).user
      refute other_user.valid?
    end

    it "requires a valid email" do
      user = build(:user, email: "invalid")
      refute user.valid?
    end

    it "requires a name" do
      user = build(:user, name: nil)
      refute user.valid?
    end
  end

  describe "#owner?" do
    it "is true when user is an owner" do
      user = create(:membership, role: Membership::OWNER).user
      assert user.owner?(company: user.current_company)
    end

    it "is false when user is not an owner" do
      user = create(:membership, role: Membership::MEMBER).user
      refute user.owner?(company: user.current_company)
    end
  end

  describe "#admin?" do
    it "is true when user is an admin" do
      user = create(:membership, role: Membership::ADMIN).user
      assert user.admin?(company: user.current_company)
    end

    it "is false when user is not an admin" do
      user = create(:membership, role: Membership::MEMBER).user
      refute user.admin?(company: user.current_company)
    end
  end

  describe "#role" do
    it "returns the user's role" do
      user = create(:membership, role: Membership::ADMIN).user
      assert_equal Membership::ADMIN, user.role(company: user.current_company)
    end
  end

  describe "#inactive?" do
    it "is true when user is inactive" do
      user = create(:membership, status: Membership::INACTIVE).user
      assert user.inactive?(company: user.current_company)
    end

    it "is false when user is active" do
      user = create(:membership, status: Membership::ACTIVE).user
      refute user.inactive?(company: user.current_company)
    end
  end

  describe "#toggle_status!" do
    it "toggles the user's status from active to inactive" do
      membership = create(:membership, status: Membership::ACTIVE)
      company = membership.company
      user = membership.user

      Stripe::SyncCustomerSubscriptionJob.stub :perform_later, nil do
        user.toggle_status!(company:)
        assert user.inactive?(company:)
      end
    end

    it "toggles the user's status from inactive to active" do
      membership = create(:membership, status: Membership::INACTIVE)
      company = membership.company
      user = membership.user

      Stripe::SyncCustomerSubscriptionJob.stub :perform_later, nil do
        user.toggle_status!(company:)
        refute user.inactive?(company:)
      end
    end

    it "toggles the company passed as an argument, not the user's current company" do
      first_membership = create(:membership, status: Membership::ACTIVE)
      user = first_membership.user
      second_membership = create(:membership, status: Membership::INACTIVE, user:)
      assert_equal second_membership.company, user.current_company

      Stripe::SyncCustomerSubscriptionJob.stub :perform_later, nil do
        user.toggle_status!(company: first_membership.company)
      end
    end

    it "syncs the customer subscription" do
      membership = create(:membership, status: Membership::ACTIVE)
      company = membership.company
      user = membership.user

      job_called = false
      Stripe::SyncCustomerSubscriptionJob.stub :perform_later, ->(arg) { 
        job_called = true
        assert_equal company, arg
      } do
        user.toggle_status!(company:)
      end
      assert job_called
    end
  end
end