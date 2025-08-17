require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  describe "validations" do
    it "requires a name" do
      company = build(:company, name: nil)
      refute company.valid?
    end

    it "does not require a unique name" do
      company = create(:company)
      other_company = build(:company, name: company.name)
      assert other_company.valid?
    end
  end
end