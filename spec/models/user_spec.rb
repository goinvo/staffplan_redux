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
    context "when user is an owner" do
      it "returns true" do
        user = create(:membership, role: Membership::OWNER).user
        expect(user.owner?).to be_truthy
      end
    end

    context "when user is not an owner" do
      it "returns false" do
        user = create(:membership, role: Membership::MEMBER).user
        expect(user.owner?).to be_falsey
      end
    end
  end
end
