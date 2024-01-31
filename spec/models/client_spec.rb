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

  describe "#active?" do
    it "returns true if status is active" do
      client = build(:client, status: "active")
      expect(client.active?).to be true
    end

    it "returns false if status is archived" do
      client = build(:client, status: "archived")
      expect(client.active?).to be false
    end
  end

  describe "archived?" do
    it "returns true if status is archived" do
      client = build(:client, status: "archived")
      expect(client.archived?).to be true
    end

    it "returns false if status is active" do
      client = build(:client, status: "active")
      expect(client.archived?).to be false
    end
  end

  describe "#toggle_archived!" do
    it "changes status from active to archived" do
      client = create(:client, status: "active")
      client.toggle_archived!
      expect(client.status).to eq("archived")
    end

    it "changes status from archived to active" do
      client = create(:client, status: "archived")
      client.toggle_archived!
      expect(client.status).to eq("active")
    end
  end
end
