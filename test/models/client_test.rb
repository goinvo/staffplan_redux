# frozen_string_literal: true

require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  describe 'validations' do
    it 'validates presence of company_id' do
      client = build(:client, company_id: nil)

      assert_not_predicate client, :valid?
      assert_includes client.errors.full_messages, 'Company must exist'
    end

    it 'validates presence of name' do
      client = build(:client, name: nil)

      assert_not_predicate client, :valid?
      assert_includes client.errors[:name], "can't be blank"
    end

    it 'validates uniqueness of company_id scoped to name' do
      existing_client = create(:client)
      duplicate_client = build(:client, company: existing_client.company, name: existing_client.name)

      assert_not_predicate duplicate_client, :valid?
      assert_includes duplicate_client.errors[:name], 'has already been taken'
    end

    it 'validates uniqueness of name scoped to company_id' do
      existing_client = create(:client)
      duplicate_client = build(:client, company: existing_client.company, name: existing_client.name)

      assert_not_predicate duplicate_client, :valid?
      assert_includes duplicate_client.errors[:name], 'has already been taken'
    end

    it 'validates presence of status' do
      client = build(:client, status: nil)

      assert_not_predicate client, :valid?
      assert_includes client.errors[:status], "can't be blank"
    end

    it 'validates inclusion of status in array' do
      client = build(:client, status: 'invalid')

      assert_not_predicate client, :valid?
      assert_includes client.errors[:status], 'is not included in the list'
    end
  end

  describe 'associations' do
    it 'belongs to company' do
      client = Client.new

      assert_respond_to client, :company
    end

    it 'has many projects with dependent destroy' do
      client = Client.new

      assert_respond_to client, :projects
    end
  end

  describe '#confirmed?' do
    it 'returns true if status is active' do
      client = build(:client, status: 'active')

      assert_predicate client, :active?
    end

    it 'returns false if status is archived' do
      client = build(:client, status: 'archived')

      assert_not_predicate client, :active?
    end
  end

  describe 'archived?' do
    it 'returns true if status is archived' do
      client = build(:client, status: 'archived')

      assert_predicate client, :archived?
    end

    it 'returns false if status is active' do
      client = build(:client, status: 'active')

      assert_not_predicate client, :archived?
    end
  end

  describe '#toggle_archived!' do
    it 'changes status from active to archived' do
      client = create(:client, status: 'active')
      client.toggle_archived!

      assert_equal 'archived', client.status
    end

    it 'changes status from archived to active' do
      client = create(:client, status: 'archived')
      client.toggle_archived!

      assert_equal 'active', client.status
    end

    it 'archives all projects when archived' do
      client = create(:client, status: 'active')
      project = create(:project, client: client, status: 'confirmed')
      client.toggle_archived!

      assert_equal 'archived', project.reload.status
    end
  end
end
