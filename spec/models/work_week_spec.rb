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
    it { should validate_numericality_of(:estimated_hours).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(24) }
    it { should validate_presence_of(:actual_hours) }
    it { should validate_numericality_of(:actual_hours).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(24) }
  end

  context "associations" do
    it { should belong_to(:assignment) }
    it { should have_one(:user) }
    it { should have_one(:project) }
  end
end
