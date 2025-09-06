# frozen_string_literal: true

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  describe 'validations' do
    it 'requires a name' do
      company = build(:company, name: nil)

      assert_not_predicate company, :valid?
    end

    it 'does not require a unique name' do
      company = create(:company)
      other_company = build(:company, name: company.name)

      assert_predicate other_company, :valid?
    end
  end
end
