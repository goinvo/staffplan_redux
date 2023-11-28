require 'rails_helper'

RSpec.describe Queries::UserStaffPlan do

  context "argument validation" do
    it "raises an error if user is not a User" do
      expect {
        Queries::UserStaffPlan.new(user: nil, company: create(:company))
      }.to raise_error(ArgumentError)
    end

    it "raises an error if company is not a Company" do
      expect {
        Queries::UserStaffPlan.new(user: create(:user), company: nil)
      }.to raise_error(ArgumentError)
    end
  end

  context "initialization" do
    it "sets a user attribute" do
      user = create(:user)
      query = Queries::UserStaffPlan.new(user: user, company: create(:company))
      expect(query.user).to eq(user)
    end

    it "sets a company attribute" do
      company = create(:company)
      query = Queries::UserStaffPlan.new(user: create(:user), company: company)
      expect(query.company).to eq(company)
    end

    it "sets an assignments attribute" do
      user = create(:user)
      company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.instance_variable_get(:@assignments)).to eq([assignment])
    end
  end

  context "work_weeks" do
    it "returns an array of work_weeks associated with the company's projects" do
      user = create(:user)
      company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      work_week = create(:work_week, assignment: assignment)
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.work_weeks).to eq([work_week])
    end

    it "does not include work_weeks from projects for other companies" do
      user = create(:user)
      company = create(:company)
      other_company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      other_assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: other_company)))
      create(:work_week, assignment: assignment)
      create(:work_week, assignment: other_assignment)
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.work_weeks).to eq(assignment.work_weeks)
    end
  end

  context "clients" do
    it "returns an array of clients associated with the company's projects" do
      user = create(:user)
      company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.clients).to eq([assignment.project.client])
    end

    it "does not include clients from projects for other companies" do
      user = create(:user)
      company = create(:company)
      other_company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      create(:assignment, user: user, project: create(:project, client: create(:client, company: other_company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.clients).to eq([assignment.project.client])
    end

    it "does not include clients for other companies" do
      user = create(:user)
      company = create(:company)
      other_company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      create(:assignment, user: user, project: create(:project, client: create(:client, company: other_company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.clients).to eq([assignment.project.client])
    end
  end

  context "projects_for(client:)" do
    it "returns an array of projects for the given client" do
      user = create(:user)
      company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.projects_for(client: assignment.project.client)).to eq([assignment.project])
    end

    it "does not include projects for other clients" do
      user = create(:user)
      company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      create(:assignment, user: user, project: create(:project, client: create(:client)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.projects_for(client: assignment.project.client)).to eq([assignment.project])
    end

    it "does not include projects for other companies" do
      user = create(:user)
      company = create(:company)
      other_company = create(:company)
      assignment = create(:assignment, user: user, project: create(:project, client: create(:client, company: company)))
      create(:assignment, user: user, project: create(:project, client: create(:client, company: other_company)))
      query = Queries::UserStaffPlan.new(user: user, company: company)
      expect(query.projects_for(client: assignment.project.client)).to eq([assignment.project])
    end
  end
end
