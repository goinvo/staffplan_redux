# frozen_string_literal: true

require 'test_helper'

class AppShellTest < ApplicationSystemTestCase
  MAIN_NAV = 'nav[aria-label=Main]'
  FEEDBACK_MAILTO = 'mailto:staffplan@goinvo.com?subject=StaffPlan%20Feedback'

  setup do
    @user = create(:membership).user
    passwordless_sign_in(@user)
  end

  test 'nav links move between pages and mark the current one' do
    with_rails_ui do
      visit people_path

      assert_current_nav_link 'People'

      within(MAIN_NAV) { click_link 'Projects' }

      assert_current_path projects_path
      assert_current_nav_link 'Projects'

      within(MAIN_NAV) { click_link 'My StaffPlan' }

      assert_current_path person_path(@user)
      assert_current_nav_link 'My StaffPlan'
    end
  end

  test 'keyboard shortcuts navigate between pages' do
    with_rails_ui do
      visit people_path

      press 'p'

      assert_current_path projects_path

      press 'm'

      assert_current_path person_path(@user)

      press 'e'

      assert_current_path people_path
    end
  end

  test 'shortcuts are ignored while typing and with modifier keys' do
    with_rails_ui do
      visit settings_profile_path
      find_field('user[name]').send_keys('p')
      find('body').send_keys([:alt, 'p'])

      assert_current_path settings_profile_path
    end
  end

  test 'the + button and n shortcut ask for the new project modal' do
    with_rails_ui do
      visit projects_path
      execute_script(<<~JS)
        window.newProjectRequests = 0
        window.addEventListener('staffplan:new-project', () => window.newProjectRequests++)
      JS

      click_button 'New project'
      within('dialog[open]') { click_button 'Cancel' }
      press 'n'

      assert_selector 'dialog[open]'
      assert_equal 2, evaluate_script('window.newProjectRequests')
    end
  end

  test 'the menu links to open source and settings' do
    with_rails_ui do
      visit people_path

      click_button 'Menu'

      assert_link 'Open Source', href: ApplicationHelper::OPEN_SOURCE_URL

      click_link 'Settings'

      assert_current_path settings_profile_path
    end
  end

  test 'the menu signs out' do
    with_rails_ui do
      visit people_path

      click_button 'Menu'
      click_button 'Sign Out'

      assert_current_path auth_sign_in_path
    end
  end

  test 'every Feedback link has the StaffPlan Feedback subject' do
    with_rails_ui do
      visit people_path

      within(MAIN_NAV) { assert_link 'Feedback', href: FEEDBACK_MAILTO }
      within('footer') { assert_link 'Feedback', href: FEEDBACK_MAILTO }

      visit settings_profile_path

      within(MAIN_NAV) { assert_link 'Feedback', href: FEEDBACK_MAILTO }
      within('footer') { assert_link 'Feedback', href: FEEDBACK_MAILTO }
    end
  end

  test 'users without the Rails UI get no + button' do
    with_config(rails_ui_enabled: '', rails_ui_emails: '') do
      visit settings_profile_path

      assert_link 'Feedback', href: FEEDBACK_MAILTO
      assert_no_button 'New project'
    end
  end

  private

  def assert_current_nav_link(label)
    assert_selector "#{MAIN_NAV} a[aria-current='page']", text: label, count: 1
    assert_selector "#{MAIN_NAV} a[aria-current='page']", count: 1
  end

  def press(key)
    find('body').send_keys(key)
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
