# frozen_string_literal: true

require 'test_helper'

class WorkWeekTest < ActiveSupport::TestCase
  describe 'validations' do
    it 'validates presence of assignment_id' do
      work_week = build(:work_week, assignment_id: nil)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors.full_messages, 'Assignment must exist'
    end

    it 'validates presence of cweek' do
      work_week = build(:work_week, cweek: nil)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:cweek], "can't be blank"
    end

    it 'validates numericality of cweek' do
      work_week = build(:work_week, cweek: 0)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:cweek], 'must be greater than or equal to 1'

      work_week = build(:work_week, cweek: 54)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:cweek], 'must be less than or equal to 53'
    end

    it 'validates presence of year' do
      work_week = build(:work_week, year: nil)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:year], "can't be blank"
    end

    it 'validates numericality of year' do
      work_week = build(:work_week, year: 1999)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:year], 'must be greater than or equal to 2000'

      work_week = build(:work_week, year: 2201)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:year], 'must be less than or equal to 2200'
    end

    it 'validates numericality of estimated_hours' do
      work_week = build(:work_week, estimated_hours: -1)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:estimated_hours], 'must be greater than or equal to 0'

      work_week = build(:work_week, estimated_hours: 169)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:estimated_hours], 'must be less than or equal to 168'
    end

    it 'validates numericality of actual_hours' do
      work_week = build(:work_week, actual_hours: -1)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:actual_hours], 'must be greater than or equal to 0'

      work_week = build(:work_week, actual_hours: 169)

      assert_not_predicate work_week, :valid?
      assert_includes work_week.errors[:actual_hours], 'must be less than or equal to 168'
    end

    it 'resets actual_hours values greater than 0 for future assignments' do
      next_month = Time.zone.today.next_month
      work_week = create(:work_week, actual_hours: 1, year: next_month.year, cweek: next_month.cweek, assignment: create(:assignment))

      assert_predicate work_week, :valid?
      assert_equal 0, work_week.reload.actual_hours
    end
  end

  describe 'associations' do
    it 'belongs to assignment' do
      work_week = WorkWeek.new

      assert_respond_to work_week, :assignment
    end

    it 'has one user' do
      work_week = WorkWeek.new

      assert_respond_to work_week, :user
    end

    it 'has one project' do
      work_week = WorkWeek.new

      assert_respond_to work_week, :project
    end
  end

  describe '#is_future_work_week?' do
    it 'returns true if the work week is in the future' do
      work_week = build(:work_week, year: Time.zone.today.cwyear, cweek: Time.zone.today.cweek + 1)

      assert_predicate work_week, :is_future_work_week?
    end

    it 'returns false if the work week is in the past' do
      work_week = build(:work_week, year: Time.zone.today.cwyear, cweek: Time.zone.today.cweek - 1)

      assert_not_predicate work_week, :is_future_work_week?
    end
  end

  describe 'callbacks' do
    it 'updates the assignment focused attribute if the work week is in the future' do
      work_week = create(:work_week, year: 1.year.from_now.to_date.cwyear, cweek: 4.weeks.from_now.to_date.cweek)
      work_week.assignment.update(focused: false)

      work_week.update(estimated_hours: 1)

      assert work_week.assignment.focused
    end

    it 'does not update the assignment focused attribute if the work week is in the past' do
      work_week = create(:work_week, year: 1.year.ago.to_date.cwyear, cweek: 4.weeks.ago.to_date.cweek)
      work_week.assignment.update(focused: false)

      work_week.update(estimated_hours: 1)

      assert_not work_week.assignment.focused
    end

    it 'does not try to update the assignment focused attribute if the work week is being deleted' do
      work_week = create(:work_week, year: 1.year.from_now.to_date.cwyear, cweek: 4.weeks.from_now.to_date.cweek)

      assert_difference('WorkWeek.count', -1) do
        work_week.assignment.destroy
      end
    end
  end
end
