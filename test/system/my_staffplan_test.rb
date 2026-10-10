# frozen_string_literal: true

require 'test_helper'

class MyStaffplanTest < ApplicationSystemTestCase
  ROWS = 'tbody tr[id^=assignment_]'

  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in(@user)
  end

  test 'shows your own assignments with a link to edit your profile' do
    assignment = assign('Acme', 'Website')

    with_rails_ui do
      visit person_path(@user)

      assert_selector 'h1', text: @user.name
      assert_link 'Edit profile', href: settings_profile_path
      assert_link 'Acme', href: projects_path(client: assignment.project.client_id)
      click_link 'Website'

      assert_current_path project_path(assignment.project)
    end
  end

  test "shows someone else's assignments without the profile link" do
    teammate = create(:membership, company: @company).user
    create(:assignment, user: teammate, project: project('Acme', 'Website'))

    with_rails_ui do
      visit person_path(teammate)

      assert_selector 'h1', text: teammate.name
      assert_selector ROWS, text: 'Website'
      assert_no_link 'Edit profile'
    end
  end

  test 'sorts by client or project and remembers the choice' do
    assign('Zeta', 'Alpha')
    assign('Beta', 'Omega')
    assign('Beta', 'Gamma')

    with_rails_ui do
      visit person_path(@user)

      assert_rows %w[Gamma Omega Alpha]

      sort_by 'Client', 'client_desc'

      assert_rows %w[Alpha Gamma Omega]

      sort_by 'Projects', 'project_asc'

      assert_rows %w[Alpha Gamma Omega]

      sort_by 'Projects', 'project_desc'

      assert_rows %w[Omega Gamma Alpha]

      visit person_path(@user)

      assert_rows %w[Omega Gamma Alpha]
    end
  end

  test 'toggles between Plan and Proposed, updating the stripes and chart' do
    assignment = assign('Acme', 'Website')
    next_week = Time.zone.today.next_week(:monday)
    create(:work_week, assignment:, cweek: next_week.cweek, year: next_week.cwyear, estimated_hours: 10, actual_hours: 0)

    with_rails_ui do
      visit person_path(@user)

      assert_no_selector 'thead path[data-proposed]', visible: :all

      click_button 'Plan'

      assert_button 'Proposed'
      assert_selector "#{ROWS}.bg-diagonal-stripes"
      assert_selector 'thead path[data-proposed]', visible: :all

      click_button 'Proposed'

      assert_button 'Plan'
      assert_no_selector "#{ROWS}.bg-diagonal-stripes"
      assert_equal Assignment::ACTIVE, assignment.reload.status
    end
  end

  test 'shows and hides hidden assignments' do
    assign('Acme', 'Website')
    hidden = assign('Acme', 'Side project', focused: false)

    with_rails_ui do
      visit person_path(@user)

      assert_rows %w[Website]
      assert_text 'Total includes hours from hidden projects'

      click_link 'Show 1 hidden project'

      assert_rows ['Side project', 'Website']

      click_button 'Show in My StaffPlan'

      assert_no_button 'Show in My StaffPlan'
      assert_no_link "Ok, only show projects I'm interested in"
      assert hidden.reload.focused

      visit person_path(@user)

      assert_rows ['Side project', 'Website']
    end
  end

  test 'a deactivated person is read-only' do
    teammate = create(:membership, company: @company)
    create(:assignment, user: teammate.user, project: project('Acme', 'Website'))
    teammate.update!(status: Membership::INACTIVE)

    with_rails_ui do
      visit person_path(teammate.user)

      assert_selector 'h1', text: '(Deactivated)'
      assert_selector ROWS, text: 'Website'
      assert_no_button 'Plan'
      assert_no_selector "#{ROWS} input[data-kind]:not([disabled])", visible: :all
    end
  end

  private

  def assert_rows(names)
    assert_selector ROWS, count: names.size
    assert_equal names, all("#{ROWS} a[href^='/projects/']").map(&:text)
  end

  def assign(client, name, **)
    create(:assignment, user: @user, project: project(client, name), **)
  end

  def project(client, name)
    client = @company.clients.find_by(name: client) || create(:client, company: @company, name: client)
    create(:project, client:, name:)
  end

  def sort_by(column, sort)
    within('#timeline thead') { click_link column }

    assert_current_path person_path(@user, sort:)
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
