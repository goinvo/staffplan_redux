# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaffPlan::WorkWeekComponent, type: :component do
  let(:assignment) { create(:assignment) }
  let(:work_week) { create(:work_week, assignment: assignment) }
  let(:work_week_beginning_of_week) { work_week.beginning_of_week }
  let(:beginning_of_week) { work_week_beginning_of_week }
  let(:component) do
    described_class.new(
      assignment: assignment,
      work_week: work_week,
      work_week_beginning_of_week: work_week_beginning_of_week,
      beginning_of_week: beginning_of_week,
      count: 0
    )
  end

  describe "#actual_hours" do
    subject { component.actual_hours }

    context "is the work week's actual_hours" do
      it { is_expected.to eq(work_week.actual_hours) }
    end
  end

  describe "#estimated_hours" do
    subject { component.estimated_hours }

    context "is the work week's estimated_hours" do
      it { is_expected.to eq(work_week.estimated_hours) }
    end
  end

  describe "#work_week_form" do
    it "renders a form with some data attributes" do
      render_inline(component)

      expect(page).to have_selector "div[data-controller='work-week']"
      expect(page).to have_css "form[data-work-week-target='form']"
      expect(page).to have_css "input[data-work-week-target='proposedInput'][data-action='blur->work-week#submit']"
      expect(page).to have_css "input[data-work-week-target='actualInput'][data-action='blur->work-week#submit']"
    end
  end

  describe "#render_actual_hours?" do
    subject { component.render_actual_hours? }

    context "when the work_week_beginning_of_week is before the beginning_of_week" do
      let(:work_week_beginning_of_week) { 2.weeks.ago.to_i }

      it { is_expected.to eq(true) }
    end

    context "when the work_week_beginning_of_week is after the beginning_of_week" do
      let(:work_week_beginning_of_week) { 2.weeks.from_now.to_i }

      it { is_expected.to eq(false) }
    end
  end
end
