require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  describe "validations" do
    it "validates presence of client_id" do
      project = build(:project, client_id: nil)
      refute project.valid?
      assert_includes project.errors[:client_id], "can't be blank"
    end

    it "validates presence of name" do
      project = build(:project, name: nil)
      refute project.valid?
      assert_includes project.errors[:name], "can't be blank"
    end

    it "validates inclusion of status in valid statuses" do
      project = build(:project, status: "invalid")
      refute project.valid?
      assert_includes project.errors[:status], "is not included in the list"
    end

    it "validates inclusion of rate_type in valid rate types" do
      project = build(:project, rate_type: "invalid")
      refute project.valid?
      assert_includes project.errors[:rate_type], "is not included in the list"
    end

    it "validates numericality of cost greater than or equal to 0" do
      project = build(:project, cost: -1)
      refute project.valid?
      assert_includes project.errors[:cost], "must be greater than or equal to 0.0"
    end

    it "validates numericality of fte greater than or equal to 0" do
      project = build(:project, fte: -1)
      refute project.valid?
      assert_includes project.errors[:fte], "must be greater than or equal to 0.0"
    end

    it "validates numericality of hours greater than or equal to 0" do
      project = build(:project, hours: -1)
      refute project.valid?
      assert_includes project.errors[:hours], "must be greater than or equal to 0"
    end

    it "validates inclusion of payment_frequency in array" do
      project = build(:project, payment_frequency: "invalid")
      refute project.valid?
      assert_includes project.errors[:payment_frequency], "is not included in the list"
    end
  end

  describe "associations" do
    it "belongs to client" do
      project = Project.new
      assert_respond_to project, :client
    end

    it "has many assignments with dependent destroy" do
      project = Project.new
      assert_respond_to project, :assignments
    end

    it "has many users through assignments" do
      project = Project.new
      assert_respond_to project, :users
    end
  end

  describe 'callbacks' do
    describe 'before_destroy: ensure_project_is_destroyable' do
      it 'allows project deletion if there are no assignments' do
        project = create(:project)

        assert_difference('Project.count', -1) do
          project.destroy
        end
        assert_raises(ActiveRecord::RecordNotFound) { project.reload }
      end

      it 'allows project deletion if there are assignments with assignees, but no actual hours' do
        project = create(:project)
        user = create(:membership, company: project.client.company).user
        assignment = create(:assignment, project: project, user: user)
        create(:work_week, assignment: assignment, actual_hours: 0)

        assert_difference('Project.count', -1) do
          project.destroy
        end
        assert_raises(ActiveRecord::RecordNotFound) { project.reload }
      end

      it 'blocks project deletion if there are assignments with actual hours' do
        project = create(:project)
        user = create(:membership, company: project.client.company).user
        assignment = create(:assignment, project: project, user: user)
        create(:work_week, assignment: assignment, actual_hours: 8)

        assert_no_difference('Project.count') do
          project.destroy
        end
        assert_includes project.errors.full_messages, "Cannot delete a project that has assignments with hours recorded. Try archiving the project instead."
      end
    end
  end

  describe 'can_be_deleted?' do
    it 'allows deletion if there are no assignments with actual hours recorded' do
      project = create(:project)
      user = create(:membership, company: project.client.company).user
      assignment = create(:assignment, project: project, user: user)
      create(:work_week, assignment: assignment, actual_hours: 0)

      assert project.can_be_deleted?
    end

    it 'blocks deletion if there are assignments with actual hours recorded' do
      project = create(:project)
      user = create(:membership, company: project.client.company).user
      assignment = create(:assignment, project: project, user: user)
      create(:work_week, assignment: assignment, actual_hours: 8)

      refute project.can_be_deleted?
    end
  end

  describe "#confirmed?" do
    it "returns true if the status is confirmed" do
      project = build(:project, status: "confirmed")
      assert_equal true, project.confirmed?
    end

    it "returns false if the status is not confirmed" do
      project = build(:project, status: "archived")
      assert_equal false, project.confirmed?
    end
  end

  describe "#archived?" do
    it "returns true if the status is archived" do
      project = build(:project, status: "archived")
      assert_equal true, project.archived?
    end

    it "returns false if the status is not archived" do
      project = build(:project, status: "active")
      assert_equal false, project.archived?
    end
  end

  describe "#unconfirmed?" do
    it "returns true if the status is unconfirmed" do
      project = build(:project, status: "unconfirmed")
      assert_equal true, project.unconfirmed?
    end

    it "returns false if the status is not unconfirmed" do
      project = build(:project, status: "confirmed")
      assert_equal false, project.unconfirmed?
    end
  end

  describe "#cancelled?" do
    it "returns true if the status is cancelled" do
      project = build(:project, status: "cancelled")
      assert_equal true, project.cancelled?
    end

    it "returns false if the status is not cancelled" do
      project = build(:project, status: "confirmed")
      assert_equal false, project.cancelled?
    end
  end

  describe "#completed?" do
    it "returns true if the status is completed" do
      project = build(:project, status: "completed")
      assert_equal true, project.completed?
    end

    it "returns false if the status is not completed" do
      project = build(:project, status: "active")
      assert_equal false, project.completed?
    end
  end
end