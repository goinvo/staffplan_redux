require 'rails_helper'

RSpec.describe Client, type: :model do
  context "validations" do
    subject { create(:client) }

    it { should validate_presence_of(:company_id) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:company_id).scoped_to(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w(active archived)) }
  end

  context "associations" do
    it { should belong_to(:company) }
    it { should have_many(:projects).dependent(:destroy) }
  end
end
