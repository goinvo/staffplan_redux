# frozen_string_literal: true

require "test_helper"

class QueryTypeTest < ActiveSupport::TestCase

  describe "assignments#canBeDeleted" do
    it "is false if the assignment is unassigned or is assigned with no actual hours" do
      query_string = <<-GRAPHQL
        query {
          projects {
            assignments {
              canBeDeleted
            }
          }
        }
      GRAPHQL

      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 15)
      company = assignment.company
      user = company.users.first

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        }
      )

      assignment_result = result["data"]["projects"].first["assignments"].first
      assert_nil result["errors"]
      assert_equal false, assignment_result["canBeDeleted"]
    end

    it "is true if the assignment is unassigned or is assigned with no actual hours" do
      query_string = <<-GRAPHQL
        query {
          projects {
            assignments {
              canBeDeleted
            }
          }
        }
      GRAPHQL

      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 0)
      company = assignment.company
      user = company.users.first

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        }
      )

      assignment_result = result["data"]["projects"].first["assignments"].first
      assert_nil result["errors"]
      assert_equal true, assignment_result["canBeDeleted"]
    end
  end

  describe "user#isActive" do
    it "is true if the user is an active member of the company" do
      query_string = <<-GRAPHQL
        query {
          viewer {
            isActive
          }
        }
      GRAPHQL

      user = create(:membership).user
      company = user.current_company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        }
      )

      user_result = result["data"]["viewer"]
      assert_nil result["errors"]
      assert_equal true, user_result["isActive"]
    end

    it "is false if the user is not an active member of the company" do
      query_string = <<-GRAPHQL
        query {
          viewer {
            isActive
          }
        }
      GRAPHQL

      user = create(:membership, status: Membership::INACTIVE).user
      company = user.current_company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        }
      )

      user_result = result["data"]["viewer"]
      assert_nil result["errors"]
      assert_equal false, user_result["isActive"]
    end

    it "considers membership status for the request's current company" do
      query_string = <<-GRAPHQL
        query {
          viewer {
            isActive
          }
        }
      GRAPHQL

      inactive_membership = create(:membership, status: Membership::INACTIVE)
      user = inactive_membership.user
      active_membership = create(:membership, status: Membership::ACTIVE, user:)

      # users.current_company is set to the active membership
      assert_equal active_membership.company, user.current_company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: inactive_membership.company
        }
      )

      user_result = result["data"]["viewer"]
      assert_nil result["errors"]
      assert_equal false, user_result["isActive"]
    end
  end

  describe "user#role" do
    it "it returns the role of the owner in the request's company" do
      query_string = <<-GRAPHQL
        query {
          viewer {
            role
          }
        }
      GRAPHQL

      user = create(:membership).user
      company = user.current_company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        }
      )

      user_result = result["data"]["viewer"]
      assert_nil result["errors"]
      assert_equal Membership::OWNER, user_result["role"]
    end

    it "it considers the request's company only" do
      query_string = <<-GRAPHQL
        query {
          viewer {
            role
          }
        }
      GRAPHQL

      active_membership = create(:membership, role: Membership::MEMBER, status: Membership::ACTIVE)
      user = active_membership.user
      inactive_membership = create(:membership, status: Membership::INACTIVE, user:)

      # users.current_company is set to the active membership
      assert_equal inactive_membership.company, user.current_company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: active_membership.company
        }
      )

      user_result = result["data"]["viewer"]
      assert_nil result["errors"]
      assert_equal Membership::MEMBER, user_result["role"]
    end
  end
end