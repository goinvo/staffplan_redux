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
end
