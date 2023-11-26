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
end
