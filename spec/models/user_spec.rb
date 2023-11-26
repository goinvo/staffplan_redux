require 'rails_helper'

RSpec.describe User, type: :model do
  context "validations" do
    it "requires a current company" do
      user = build(:user)
      user.current_company = nil
      expect(user).to_not be_valid
    end

    it "requires a unique email" do
      user = create(:user)
      other_user = build(:user, email: user.email)
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
end
