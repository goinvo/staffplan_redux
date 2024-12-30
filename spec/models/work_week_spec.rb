require 'rails_helper'

RSpec.describe WorkWeek, type: :model do
  context "validations" do
    subject { create(:work_week) }

    it { should validate_presence_of(:assignment_id) }
    it { should validate_presence_of(:cweek) }
    it { should validate_numericality_of(:cweek).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(53) }
    it { should validate_presence_of(:year) }
    it { should validate_numericality_of(:year).only_integer.is_greater_than_or_equal_to(2000).is_less_than_or_equal_to(2200) }
    it { should validate_presence_of(:estimated_hours) }
    it { should validate_numericality_of(:estimated_hours).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(168) }
    it { should validate_presence_of(:actual_hours) }
    it { should validate_numericality_of(:actual_hours).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(168) }

    it 'resets actual_hours values greater than 0 for future assignments' do
      next_month = Date.today.next_month
      work_week = create(:work_week, actual_hours: 1, year: next_month.year, cweek: next_month.cweek, assignment: create(:assignment))

      expect(work_week).to be_valid
      expect(work_week.reload.actual_hours).to eql(0)
    end
  end

  context "associations" do
    it { should belong_to(:assignment) }
    it { should have_one(:user) }
    it { should have_one(:project) }
  end

  context "#is_future_work_week?" do
    it "returns true if the work week is in the future" do
      work_week = build(:work_week, year: Date.today.cwyear, cweek: Date.today.cweek + 1)
      expect(work_week.is_future_work_week?).to be_truthy
    end

    it "returns false if the work week is in the past" do
      work_week = build(:work_week, year: Date.today.cwyear, cweek: Date.today.cweek - 1)
      expect(work_week.is_future_work_week?).to be_falsey
    end
  end
end
