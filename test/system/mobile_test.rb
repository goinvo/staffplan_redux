# frozen_string_literal: true

require 'test_helper'

class MobileTest < ApplicationSystemTestCase
  WEEKS = '#timeline thead th[data-timeline-week]'

  setup do
    travel_to Date.new(2026, 10, 8)
    @user = create(:membership).user
    @user.update!(name: 'Ann Lee')
    @website = assignment_for_user(user: @user)
    @rebrand = assignment_for_user(user: @user)
    [[@website, 30], [@rebrand, 10]].each do |assignment, hours|
      (40..42).each { create(:work_week, assignment:, cweek: it, year: 2026, estimated_hours: hours, actual_hours: 0) }
    end
    passwordless_sign_in(@user)
    page.driver.browser.manage.window.resize_to(400, 800)
  end

  teardown do
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test 'shows one week at a time and swipes between weeks' do
    visit person_path(@user)

    assert_selector 'th', text: 'Ann Lee'
    assert_selector WEEKS, count: 1, text: '5'

    swipe(from: 300, to: 100)

    assert_current_path person_path(@user, start: '2026-10-05')
    assert_selector WEEKS, count: 1, text: '12'

    swipe(from: 100, to: 300)

    assert_current_path person_path(@user, start: '2026-09-28')

    swipe(from: 100, to: 300)

    assert_current_path person_path(@user, start: '2026-09-21')
    assert_selector WEEKS, count: 1, text: '28'
  end

  test "approving the shown week records each project's plan as actual hours" do
    visit person_path(@user)
    click_button 'Yes, I worked 40 hrs'

    assert_no_button 'Yes, I worked 40 hrs'
    assert_field "#{@website.project.name} actual hours, week of Oct 5, 2026", with: '30'

    assert_equal([30, 10], [@website, @rebrand].map { it.work_weeks.find_by!(cweek: 41).actual_hours })
  end

  test 'future weeks offer no approval' do
    visit person_path(@user, start: '2026-10-12')

    assert_text 'I need to see the full plan.'
    assert_no_button(/Yes, I worked/)
  end

  private

  def swipe(from:, to:)
    execute_script(<<~JS, from, to)
      const touch = (x) => new Touch({ identifier: 1, target: document.body, clientX: x, clientY: 200 })
      window.dispatchEvent(new TouchEvent("touchstart", { changedTouches: [touch(arguments[0])] }))
      window.dispatchEvent(new TouchEvent("touchend", { changedTouches: [touch(arguments[1])] }))
    JS
  end
end
