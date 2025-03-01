# frozen_string_literal: true

require "rails_helper"

RSpec.describe "QueryType" do

  context "assignments#canBeDeleted" do
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

      assignment = result["data"]["projects"].first["assignments"].first
      expect(result["errors"]).to be_nil
      expect(assignment["canBeDeleted"]).to eq(false)
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

      assignment = result["data"]["projects"].first["assignments"].first
      expect(result["errors"]).to be_nil
      expect(assignment["canBeDeleted"]).to eq(true)
    end
  end

  context "user#isActive" do
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

      user = result["data"]["viewer"]
      expect(result["errors"]).to be_nil
      expect(user["isActive"]).to eq(true)
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

      user = result["data"]["viewer"]
      expect(result["errors"]).to be_nil
      expect(user["isActive"]).to eq(false)
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

      user = result["data"]["viewer"]
      expect(result["errors"]).to be_nil
      expect(user["isActive"]).to eq(false)
    end
  end

  context "user#role" do
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

      user = result["data"]["viewer"]
      expect(result["errors"]).to be_nil
      expect(user["role"]).to eq(Membership::OWNER)
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

      user = result["data"]["viewer"]
      expect(result["errors"]).to be_nil
      expect(user["role"]).to eq(Membership::MEMBER)
    end
  end
end
