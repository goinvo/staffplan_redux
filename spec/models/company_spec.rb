require 'rails_helper'

RSpec.describe Company, type: :model do
  context "validations" do
    it "requires a name" do
      company = build(:company, name: nil)
      expect(company).to_not be_valid
    end

    it "requires a unique name" do
      company = create(:company)
      other_company = build(:company, name: company.name)
      expect(other_company).to_not be_valid
    end
  end
end
