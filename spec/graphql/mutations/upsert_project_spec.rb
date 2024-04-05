# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertProject do

  context "resolve" do
    it "creates a new project with valid params" do
      query_string = <<-GRAPHQL
        mutation($clientId: ID, $name: String, $status: String) {
          upsertProject(clientId: $clientId, name: $name, status: $status) {
            id
            client {
              id
            }
            name
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      user = create(:user)
      client = create(:client, company: user.current_company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          clientId: client.id,
          name: project_name = Faker::Company.buzzword,
          status: Project::UNCONFIRMED
        }
      )

      post_result = result["data"]["upsertProject"]
      expect(result["errors"]).to be_nil
      expect(post_result["client"]["id"]).to eq(client.id.to_s)
      expect(post_result["name"]).to eq(project_name)
      expect(post_result["status"]).to eq(Project::UNCONFIRMED)
      expect(post_result["startsOn"]).to be_nil
      expect(post_result["endsOn"]).to be_nil
    end

    it "does not allow a client_id from another company to be specified" do
      query_string = <<-GRAPHQL
        mutation($clientId: ID, $name: String) {
          upsertProject(clientId: $clientId, name: $name) {
            id
            client {
              id
            }
            name
          }
        }
      GRAPHQL

      user = create(:user)
      client = create(:client, company: user.current_company)
      other_client = create(:client)

      expect(client.company).to_not eq(other_client.company)
      expect(other_client.company.users).to_not include(user)
      result = nil

      expect do
        result = StaffplanReduxSchema.execute(
          query_string,
          context: {
            current_user: user,
            current_company: user.current_company
          },
          variables: {
            clientId: other_client.id,
            name: project_name = Faker::Company.buzzword
          }
        )
      end.to_not change(Project, :count)

      post_result = result["errors"]
      expect(post_result.first["message"]).to eq("Client not found")
    end

    it "updates a project with valid params" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $clientId: ID, $name: String, $status: String, $cost: Float, $paymentFrequency: String, $fte: Float, $hours: Int, $startsOn: ISO8601Date, $endsOn: ISO8601Date) {
          upsertProject(id: $id, clientId: $clientId, name: $name, status: $status, cost: $cost, paymentFrequency: $paymentFrequency, fte: $fte, hours: $hours, startsOn: $startsOn, endsOn: $endsOn) {
            id
            client {
              id
            }
            name
            cost
            paymentFrequency
            fte
            hours
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      project = create(:project)
      user = User.find_by(current_company_id: project.company.id)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: project.id,
          clientId: project.client.id,
          name: project.name + " updated",
          status: Project::COMPLETED,
          cost: 1000.00,
          paymentFrequency: Project::ANNUALLY,
          fte: 1.25,
          hours: 1_000,
          startsOn: starts_on = 2.weeks.from_now.to_date.iso8601,
          endsOn: ends_on = 10.weeks.from_now.to_date.iso8601
        }
      )

      post_result = result["data"]["upsertProject"]
      expect(result["errors"]).to be_nil
      expect(post_result["client"]["id"]).to eq(project.client.id.to_s)
      expect(post_result["name"]).to eq(project.name + " updated")
      expect(post_result["status"]).to eq(Project::COMPLETED)
      expect(post_result["cost"]).to eq(1000.00)
      expect(post_result["paymentFrequency"]).to eq(Project::ANNUALLY)
      expect(post_result["fte"]).to eq(1.25)
      expect(post_result["hours"]).to eq(1_000)
      expect(post_result["startsOn"]).to eq(starts_on.to_s)
      expect(post_result["endsOn"]).to eq(ends_on.to_s)
    end

    it "does not allow client_id to be overridden" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $clientId: ID) {
          upsertProject(id: $id, clientId: $clientId) {
            id
            client {
              id
            }
          }
        }
      GRAPHQL

      project = create(:project)
      user = project.company.users.first
      other_client = create(:client)

      expect(project.client.company).to_not eq(other_client.company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: project.id,
          clientId: other_client.id,
        }
      )

      post_result = result["data"]["upsertProject"]
      expect(post_result["client"]["id"]).to eq(project.client.id.to_s)
    end

    it "raises a 404 if given an project id that doesn't exist on the company" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $name: String) {
          upsertProject(id: $id, name: $name) {
            id
            name
          }
        }
      GRAPHQL

      project = create(:project)
      user = project.company.users.first
      second_project = create(:project)

      expect(project.company).to_not eq(second_project.company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: second_project.id,
          name: "new name"
        }
      )

      post_result = result["errors"]
      expect(post_result.first["message"]).to eq("Project not found")
    end
  end
end