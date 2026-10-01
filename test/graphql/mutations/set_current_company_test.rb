# frozen_string_literal: true

require 'test_helper'

module Mutations
  class SetCurrentCompanyTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($companyId: ID!) {
        setCurrentCompany(companyId: $companyId) {
          id
          name
        }
      }
    GRAPHQL

    test 'succeeds if the user is an active member of the company' do
      membership = create(:membership)
      user = membership.user
      other_company = create(:membership, user:).company

      result = execute_graphql(QUERY, user:, company: membership.company, variables: { companyId: other_company.id })

      post_result = result['data']['setCurrentCompany']

      assert_equal other_company.id.to_s, post_result['id']
      assert_equal other_company.name, post_result['name']
    end

    test 'fails if the user is not an active member of the company' do
      membership = create(:membership)
      user = membership.user
      other_company = create(:membership, status: Membership::INACTIVE, user:).company

      result = execute_graphql(QUERY, user:, company: membership.company, variables: { companyId: other_company.id })

      assert_equal 1, result['errors'].length
      assert_equal 'Company not found.', result['errors'].first['message']
    end

    test 'fails if the user has no membership with the company' do
      membership = create(:membership)
      user = membership.user
      other_company = create(:membership).company

      assert_not_includes other_company.users, user

      result = execute_graphql(QUERY, user:, company: membership.company, variables: { companyId: other_company.id })

      assert_equal 1, result['errors'].length
      assert_equal 'Company not found.', result['errors'].first['message']
    end
  end
end
