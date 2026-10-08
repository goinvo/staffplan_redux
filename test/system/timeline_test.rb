# frozen_string_literal: true

require 'test_helper'

class TimelineTest < ApplicationSystemTestCase
  WEEK_HEADERS = '#timeline thead tr:nth-child(2) th[data-timeline-week]'

  setup do
    @user = create(:membership).user
    @start = Time.zone.today.beginning_of_week(:monday) - 1.week
    passwordless_sign_in(@user)
  end

  test 'resizing changes the visible weeks without a request' do
    with_rails_ui do
      resize_to 1000
      visit person_path(@user)
      execute_script("document.getElementById('timeline').dataset.marker = 'same page'")

      narrow = assert_visible_weeks

      resize_to 1600

      assert_operator assert_visible_weeks, :>, narrow

      resize_to 500

      assert_selector WEEK_HEADERS, count: 1
      assert_selector "#{WEEK_HEADERS}[aria-current=date]"
      assert_selector "#timeline[data-marker='same page']"
    end
  end

  test 'arrows and arrow keys page by the visible week count' do
    with_rails_ui do
      resize_to 1000
      visit person_path(@user)

      weeks = assert_visible_weeks

      click_link 'Next weeks'

      assert_current_path person_path(@user, start: (@start + weeks.weeks).iso8601)
      assert_link 'Today'

      press :right

      assert_current_path person_path(@user, start: (@start + (2 * weeks).weeks).iso8601)

      press :left

      assert_current_path person_path(@user, start: (@start + weeks.weeks).iso8601)

      press :left

      assert_current_path person_path(@user, start: @start.iso8601)

      click_link 'Previous weeks'

      assert_current_path person_path(@user, start: (@start - weeks.weeks).iso8601)

      click_link 'Today'

      assert_current_path person_path(@user)
      assert_no_link 'Today'
    end
  end

  test 'arrow keys with modifiers do not page' do
    with_rails_ui do
      visit person_path(@user)
      find('body').send_keys(%i[alt right])

      assert_current_path person_path(@user)
    end
  end

  private

  # React's formula: 600px base + 60px gutter, 42px per extra week, at least 5,
  # plus the leading week before the current one
  def assert_visible_weeks
    width = evaluate_script('document.documentElement.clientWidth')
    expected = [5, 1 + ((width - 660) / 42)].max + 1

    assert_selector WEEK_HEADERS, count: expected
    expected
  end

  def press(key)
    find('body').send_keys(key)
  end

  def resize_to(width)
    page.current_window.resize_to(width, 1000)
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
