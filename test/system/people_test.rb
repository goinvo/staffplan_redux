# frozen_string_literal: true

require 'test_helper'

class PeopleTest < ApplicationSystemTestCase
  ROWS = 'tbody tr[id^=user_]'

  setup do
    @company = create(:company)
    @membership = @company.memberships.sole
    @user = @membership.user
    @user.update!(name: 'Ann')
    passwordless_sign_in(@user)
  end

  test 'cycles the sort from least covered through alpha and remembers it' do
    bo = teammate('Bo')
    cy = teammate('Cy')
    plan(@user, 10)
    plan(bo, 40)

    with_rails_ui do
      visit people_path

      assert_sorted 'least covered', %w[Cy Ann Bo]
      within("tr#user_#{bo.id}") { assert_text '40' }

      click_sort 'most_covered'

      assert_sorted 'most covered', %w[Bo Ann Cy]

      click_sort 'alpha_asc'

      assert_sorted 'alpha', %w[Ann Bo Cy]

      click_sort 'alpha_desc'

      assert_sorted 'alpha', %w[Cy Bo Ann]

      visit people_path

      assert_sorted 'alpha', %w[Cy Bo Ann]

      click_link cy.name

      assert_current_path person_path(cy)
    end
  end

  test 'shows and hides deactivated people' do
    dee = teammate('Dee')
    plan(dee, 12)
    @company.memberships.find_by!(user: dee).update!(status: Membership::INACTIVE)

    with_rails_ui do
      visit people_path

      assert_people %w[Ann]

      click_link 'Show 1 deactivated person'

      assert_people ['Ann', 'Dee (Deactivated)']

      click_link 'Hide 1 deactivated person'

      assert_people %w[Ann]
    end
  end

  test 'only owners and admins get the add people link' do
    with_rails_ui do
      visit people_path
      click_link 'Add people'

      assert_current_path settings_users_path

      @membership.update!(role: Membership::MEMBER)
      visit people_path

      assert_people %w[Ann]
      assert_no_link 'Add people'

      @membership.update!(role: Membership::ADMIN)
      visit people_path

      assert_link 'Add people', href: settings_users_path
    end
  end

  private

  def assert_people(names)
    assert_selector ROWS, count: names.size
    assert_equal(names, all("#{ROWS} a[href^='/people/']").map { it.text.squish })
  end

  def assert_sorted(label, names)
    within('#timeline thead') { assert_link "People (#{label})" }
    assert_people names
  end

  def click_sort(sort)
    within('#timeline thead') { click_link 'People' }

    assert_current_path people_path(sort:)
  end

  def plan(user, hours)
    next_week = Time.zone.today.next_week(:monday)
    assignment = create(:assignment, user:, project: project_for_company(@company))
    create(:work_week, assignment:, cweek: next_week.cweek, year: next_week.cwyear, estimated_hours: hours, actual_hours: 0)
  end

  def teammate(name)
    create(:membership, company: @company, role: Membership::MEMBER).user.tap { it.update!(name:) }
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
