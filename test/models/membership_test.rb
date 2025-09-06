# frozen_string_literal: true

require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  describe 'validations' do
    it 'requires a user' do
      membership = build(:membership, user: nil)

      assert_not_predicate membership, :valid?
    end

    it 'requires a company' do
      membership = build(:membership, company: nil)

      assert_not_predicate membership, :valid?
    end

    it 'requires a unique user scoped to company' do
      membership = create(:membership)
      other_membership = build(:membership, user: membership.user, company: membership.company)

      assert_not_predicate other_membership, :valid?
    end

    it 'requires a status' do
      membership = build(:membership, status: nil)

      assert_not_predicate membership, :valid?
    end

    it 'requires a valid status' do
      membership = build(:membership, status: 'invalid')

      assert_not_predicate membership, :valid?
    end

    it 'requires a role' do
      membership = build(:membership, role: nil)

      assert_not_predicate membership, :valid?
    end

    it 'requires a valid role' do
      membership = build(:membership, role: 'invalid')

      assert_not_predicate membership, :valid?
    end
  end

  describe '#confirmed?' do
    it 'returns true if status is active' do
      membership = build(:membership, status: 'active')

      assert_predicate membership, :active?
    end

    it 'returns false if status is not active' do
      membership = build(:membership, status: 'inactive')

      assert_not_predicate membership, :active?
    end
  end
end
