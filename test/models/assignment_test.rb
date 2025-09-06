# frozen_string_literal: true

require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  describe 'validations' do
    it 'validates presence of project_id' do
      assignment = build(:assignment)
      assignment.project_id = nil
      assignment.project = nil

      assert_not_predicate assignment, :valid?
      assert_includes assignment.errors[:project_id], "can't be blank"
    end

    it 'validates uniqueness of project_id scoped to user_id' do
      assignment = create(:assignment)
      duplicate = build(:assignment, project: assignment.project, user: assignment.user)

      assert_not_predicate duplicate, :valid?
      assert_includes duplicate.errors[:project_id], 'has already been taken'
    end

    it 'validates presence of status' do
      assignment = build(:assignment, status: nil)

      assert_not_predicate assignment, :valid?
      assert_includes assignment.errors[:status], "can't be blank"
    end

    it 'validates inclusion of status in array' do
      assignment = build(:assignment, status: 'invalid')

      assert_not_predicate assignment, :valid?
      assert_includes assignment.errors[:status], 'is not included in the list'
    end

    it "does not validates user / project uniqueness if the status is not 'active'" do
      first_assignment = build(:assignment, status: Assignment::PROPOSED)
      second_assignment = build(:assignment, project: first_assignment.project, status: Assignment::PROPOSED)
      first_assignment.update!(user_id: nil)
      second_assignment.update!(user_id: nil)

      assert_predicate first_assignment, :valid?
      assert_predicate second_assignment, :valid?
    end

    it 'requires a user if the status is active' do
      assignment = create(:assignment, status: Assignment::ACTIVE)
      assignment.assign_attributes(user_id: nil)

      assert_not_predicate assignment, :valid?
      assert_not assignment.save
      assignment.reload

      assert_not_nil assignment.user
    end

    it 'disallows saving non-proposed assignments with no assignee' do
      assignment = Assignment.new(
        project: create(:project),
        status: Assignment::ACTIVE,
        user: nil,
      )

      assert_not_predicate assignment, :valid?
      assert_not assignment.save
    end

    it "does not require a user if the status is not 'active'" do
      assignment = build(:assignment, status: Assignment::PROPOSED, user: nil)

      assert_predicate assignment, :valid?
    end

    it 'does not let an assigned assignment be destroyed that has hours logged' do
      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 15)

      assert_predicate assignment, :persisted?
      assert_equal Assignment::ACTIVE, assignment.status

      assignment.destroy

      assert_predicate assignment, :persisted?
      assert_equal ["Cannot delete an assignment that's assigned with hours recorded. Try archiving the assignment instead."], assignment.errors.full_messages
    end
  end

  describe 'associations' do
    it 'belongs to project' do
      assignment = Assignment.new

      assert_respond_to assignment, :project
    end

    it 'has many work weeks' do
      assignment = Assignment.new

      assert_respond_to assignment, :work_weeks
    end
  end

  describe 'starts_on and ends_on' do
    it 'does not allow starts_on to be after ends_on' do
      assignment = build(:assignment, starts_on: Time.zone.today, ends_on: 3.days.ago.to_date)

      assert_not_predicate assignment, :valid?
      assert_includes assignment.errors[:starts_on], "can't be after the assignment ends"
    end

    it 'does not allow ends_on to be before starts_on' do
      assignment = build(:assignment, starts_on: Date.tomorrow, ends_on: Time.zone.today)

      assert_not_predicate assignment, :valid?
      assert_includes assignment.errors[:ends_on], "can't come before the assignment starts"
    end
  end

  describe '#project_and_user_belong_to_same_company' do
    it 'validates that the user and project belong to the same company' do
      user = create(:user)
      project = create(:project)
      assignment = build(:assignment, user: user, project: project)

      assert_not_includes project.company.active_users, user

      assert_not_predicate assignment, :valid?
      assert_equal ['and user must belong to the same company'], assignment.errors[:project]
    end
  end
end
