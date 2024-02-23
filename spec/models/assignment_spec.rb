require 'rails_helper'

RSpec.describe Assignment, type: :model do
  context "validations" do
    subject { create(:assignment) }

    it { should validate_presence_of(:user_id) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:project_id) }
    it { should validate_presence_of(:project_id) }
    it { should validate_uniqueness_of(:project_id).scoped_to(:user_id) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w(proposed active archived completed)) }
  end

  context "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
    it { should have_many(:work_weeks) }
  end

  context "starts_on and ends_on" do
    it "does not allow starts_on to be after ends_on" do
      assignment = build(:assignment, starts_on: Date.today, ends_on: Date.yesterday)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:starts_on]).to include("can't be after the assignment ends")
    end

    it "does not allow ends_on to be before starts_on" do
      assignment = build(:assignment, starts_on: Date.tomorrow, ends_on: Date.today)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:ends_on]).to include("can't come before the assignment starts")
    end

    it "does not allow ends_on to be set without starts_on" do
      assignment = build(:assignment, starts_on: nil, ends_on: Date.today)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:starts_on]).to include("is required if an end date is set")
    end

    it "does not allow starts_on to be set without ends_on" do
      assignment = build(:assignment, starts_on: Date.today, ends_on: nil)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:ends_on]).to include("is required if a start date is set")
    end
  end

  describe "#project_and_user_belong_to_same_company" do
    it "validates that the user and project belong to the same company" do
      user = create(:user)
      project = create(:project)
      assignment = build(:assignment, user: user, project: project)
      expect(project.company.active_users).to_not include(user)

      expect(assignment).to_not be_valid
      expect(assignment.errors[:project]).to eql(["and user must belong to the same company"])
    end
  end
end
