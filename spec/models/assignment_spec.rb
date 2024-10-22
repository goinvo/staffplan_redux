require 'rails_helper'

RSpec.describe Assignment, type: :model do
  context "validations" do
    subject { create(:assignment) }

    it { should validate_presence_of(:project_id) }
    it { should validate_uniqueness_of(:project_id).scoped_to(:user_id) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w(proposed active archived completed)) }

    it "does not validates user / project uniqueness if the status is not 'active'" do
      first_assignment = build(:assignment, status: Assignment::PROPOSED)
      second_assignment = build(:assignment, project: first_assignment.project, status: Assignment::PROPOSED)
      first_assignment.update!(user_id: nil)
      second_assignment.update!(user_id: nil)

      expect(first_assignment).to be_valid
      expect(second_assignment).to be_valid
    end

    it "requires a user if the status is active" do
      assignment = create(:assignment, status: Assignment::ACTIVE)
      assignment.assign_attributes(user_id: nil)

      expect(assignment).to_not be_valid
      expect(assignment.save).to be_falsey
      assignment.reload
      expect(assignment.user).to_not be_nil
    end

    it 'disallows saving non-proposed assignments with no assignee' do
      assignment = Assignment.new(
        project: create(:project),
        status: Assignment::ACTIVE,
        user: nil
      )
      expect(assignment).to_not be_valid
      expect(assignment.save).to be_falsey
    end

    it "does not require a user if the status is not 'active'" do
      assignment = build(:assignment, status: Assignment::PROPOSED, user: nil)
      expect(assignment).to be_valid
    end

    it "does not let an assigned assignment be destroyed that has hours logged" do
      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 15)

      expect(assignment.persisted?).to eq(true)
      expect(assignment.status).to eq(Assignment::ACTIVE)

      assignment.destroy

      expect(assignment.persisted?).to eq(true)
      expect(assignment.errors.full_messages).to eq(["Cannot delete an assignment that's assigned with hours recorded. Try archiving the assignment instead."])
    end
  end

  context "associations" do
    it { should belong_to(:project) }
    it { should have_many(:work_weeks) }
  end

  context "starts_on and ends_on" do
    it "does not allow starts_on to be after ends_on" do
      assignment = build(:assignment, starts_on: Date.today, ends_on: 3.days.ago.to_date)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:starts_on]).to include("can't be after the assignment ends")
    end

    it "does not allow ends_on to be before starts_on" do
      assignment = build(:assignment, starts_on: Date.tomorrow, ends_on: Date.today)
      expect(assignment).to_not be_valid
      expect(assignment.errors[:ends_on]).to include("can't come before the assignment starts")
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
