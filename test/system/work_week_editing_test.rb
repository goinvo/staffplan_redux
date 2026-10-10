# frozen_string_literal: true

require 'test_helper'

class WorkWeekEditingTest < ApplicationSystemTestCase
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @this_monday = Time.zone.today.beginning_of_week(:monday)
    @website = assignment('Acme', 'Website')
    @mobile = assignment('Acme', 'Mobile app')
    passwordless_sign_in(@user)
  end

  test 'typing and tabbing saves and updates the totals without a reload' do
    with_rails_ui do
      visit_page

      plan(@website, 1).click
      plan(@website, 1).send_keys('20', :tab)

      assert_focused plan(@website, 2)
      assert_selector chart_label(1), text: '20'
      within("##{dom_id(@website)} td:last-child") { assert_text '20hrs' }
      assert evaluate_script("document.getElementById('timeline').samePage"), 'the grid was morphed in place'
      assert_equal [20], @website.work_weeks.pluck(:estimated_hours)
    end
  end

  test 'enter saves and escape reverts' do
    create(:work_week, assignment: @website, cweek: week(1).cweek, year: week(1).cwyear, estimated_hours: 10, actual_hours: 0)

    with_rails_ui do
      visit_page

      plan(@website, 1).click
      plan(@website, 1).send_keys('30', :escape)

      assert_equal '10', plan(@website, 1).value

      plan(@website, 1).send_keys('12', :enter)

      assert_selector chart_label(1), text: '12'
      assert_focused plan(@website, 1)
      assert_equal [12], @website.work_weeks.reload.pluck(:estimated_hours)
    end
  end

  test 'actual hours save for the current week' do
    with_rails_ui do
      visit_page

      actual(@website, 0).click
      actual(@website, 0).send_keys('7', :tab)

      assert_focused actual(@website, 1)
      assert_selector chart_label(0), text: '7'
      assert_equal [[week(0).cweek, 7]], @website.work_weeks.pluck(:cweek, :actual_hours)
    end
  end

  test 'arrow keys and tab move around the grid' do
    with_rails_ui do
      visit_page

      plan(@mobile, 0).click
      plan(@mobile, 0).send_keys(:right)

      assert_focused plan(@mobile, 1)

      plan(@mobile, 1).send_keys(:down)

      assert_focused actual(@mobile, 1)

      actual(@mobile, 1).send_keys(:down)

      assert_focused plan(@website, 1)

      plan(@website, 1).send_keys(:up)

      assert_focused actual(@mobile, 1)

      actual(@mobile, 1).send_keys(:up)

      assert_focused plan(@mobile, 1)

      plan(@mobile, 1).send_keys(:left)

      assert_focused plan(@mobile, 0)

      last_plan = all("##{dom_id(@mobile)} input[data-kind=plan]").to_a.rfind(&:visible?)
      last_plan.click
      last_plan.send_keys(:tab)

      assert_focused actual(@mobile, 0)

      actual(@mobile, 0).send_keys(%i[shift tab])

      assert_focused last_plan
    end
  end

  test 'fill forward copies the plan to the following visible weeks' do
    with_rails_ui do
      visit_page

      plan(@website, 2).click
      plan(@website, 2).send_keys('8')
      find("##{dom_id(@website)} td[data-timeline-week='2'] button[aria-label='Fill forward']").click

      last_week = all("##{dom_id(@website)} td[data-monday]").to_a.rfind(&:visible?)['data-monday']

      assert_selector chart_label(3), text: '8'
      assert_equal ((Date.iso8601(last_week) - week(2)).to_i / 7) + 1, @website.work_weeks.where(estimated_hours: 8).count
    end
  end

  test 'explains why more than 168 hours is refused' do
    with_rails_ui do
      visit_page

      plan(@website, 1).click
      plan(@website, 1).send_keys('169')

      assert_equal '16', plan(@website, 1).value
      assert_selector '[role=alert]', text: 'There are only 168 hours in a week'

      plan(@website, 1).send_keys(:backspace)

      assert_no_selector '[role=alert]'
    end
  end

  private

  def actual(assignment, offset) = find("#actHours-#{assignment.id}-#{week(offset).cweek}-#{week(offset).cwyear}")

  def assert_focused(input)
    assert_equal input[:id], evaluate_script('document.activeElement.id')
  end

  def assignment(client, name)
    client = @company.clients.find_by(name: client) || create(:client, company: @company, name: client)
    create(:assignment, user: @user, project: create(:project, client:, name:), starts_on: nil, ends_on: nil)
  end

  def chart_label(index) = "#timeline thead tr:first-child th[data-timeline-week='#{index}'] span"

  def plan(assignment, offset) = find("#estHours-#{assignment.id}-#{week(offset).cweek}-#{week(offset).cwyear}")

  def visit_page
    visit person_path(@user)
    execute_script("document.getElementById('timeline').samePage = true")
  end

  def week(offset) = @this_monday + (offset - 1).weeks

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
