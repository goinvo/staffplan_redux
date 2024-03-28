require 'rails_helper'

RSpec.describe Project, type: :model do
  context "validations" do
    subject { create(:project) }

    it { should validate_presence_of(:client_id) }
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:status).in_array(Project::VALID_STATUSES) }
    it { should validate_numericality_of(:cost).is_greater_than_or_equal_to(0.0) }
    it { should validate_inclusion_of(:payment_frequency).in_array(%w(weekly monthly fortnightly quarterly annually)) }
  end

  context "associations" do
    it { should belong_to(:client) }
    it { should have_many(:assignments).dependent(:destroy) }
    it { should have_many(:users).through(:assignments) }
  end

  describe "#confirmed?" do
    it "returns true if the status is confirmed" do
      project = build(:project, status: "confirmed")
      expect(project.confirmed?).to eq(true)
    end

    it "returns false if the status is not confirmed" do
      project = build(:project, status: "archived")
      expect(project.confirmed?).to eq(false)
    end
  end

  describe "#archived?" do
    it "returns true if the status is archived" do
      project = build(:project, status: "archived")
      expect(project.archived?).to eq(true)
    end

    it "returns false if the status is not archived" do
      project = build(:project, status: "active")
      expect(project.archived?).to eq(false)
    end
  end

  describe "#unconfirmed?" do
    it "returns true if the status is unconfirmed" do
      project = build(:project, status: "unconfirmed")
      expect(project.unconfirmed?).to eq(true)
    end

    it "returns false if the status is not unconfirmed" do
      project = build(:project, status: "confirmed")
      expect(project.unconfirmed?).to eq(false)
    end
  end

  describe "#cancelled?" do
    it "returns true if the status is cancelled" do
      project = build(:project, status: "cancelled")
      expect(project.cancelled?).to eq(true)
    end

    it "returns false if the status is not cancelled" do
      project = build(:project, status: "confirmed")
      expect(project.cancelled?).to eq(false)
    end
  end

  describe "#completed?" do
    it "returns true if the status is completed" do
      project = build(:project, status: "completed")
      expect(project.completed?).to eq(true)
    end

    it "returns false if the status is not completed" do
      project = build(:project, status: "active")
      expect(project.completed?).to eq(false)
    end
  end
end
