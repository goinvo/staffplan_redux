require 'rails_helper'

RSpec.describe Project, type: :model do
  context "validations" do
    subject { create(:project) }

    it { should validate_presence_of(:client_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w(active archived)) }
    it { should validate_presence_of(:cost) }
    it { should validate_numericality_of(:cost).is_greater_than_or_equal_to(0.0) }
    it { should validate_presence_of(:payment_frequency) }
    it { should validate_inclusion_of(:payment_frequency).in_array(%w(weekly monthly fortnightly quarterly annually)) }
  end

  context "associations" do
    it { should belong_to(:client) }
    it { should have_many(:assignments).dependent(:destroy) }
    it { should have_many(:users).through(:assignments) }
  end
end
