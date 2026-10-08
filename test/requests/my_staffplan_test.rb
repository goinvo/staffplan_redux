# frozen_string_literal: true

require 'test_helper'

class MyStaffplanTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in @user
  end

  test 'lists assignments, leaving out archived projects and hidden assignments' do
    assign('Acme', 'Website')
    assign('Acme', 'Old site').project.update!(status: Project::ARCHIVED)
    assign('Acme', 'Side project', focused: false)

    show_person

    assert_dom 'tbody tr[id^=assignment_]', count: 1
    assert_dom 'tbody a', text: 'Website'
    assert_dom 'tbody a', text: 'Show 1 hidden project'
    assert_dom 'tbody', text: /Total includes hours from hidden projects/
  end

  test 'shows hidden assignments on request' do
    assign('Acme', 'Website')
    assign('Acme', 'Side project', focused: false)

    show_person(show_hidden: 1)

    assert_dom 'tbody tr[id^=assignment_]', count: 2
    assert_dom 'button[aria-label="Show in My StaffPlan"]', count: 1
    assert_dom 'tbody a', text: "Ok, only show projects I'm interested in"
  end

  test "someone else's hidden assignments stay hidden" do
    teammate = create(:membership, company: @company).user
    create(:assignment, user: teammate, project: project('Acme', 'Website'))
    create(:assignment, user: teammate, project: project('Acme', 'Side project'), focused: false)

    show_person(teammate, show_hidden: 1)

    assert_dom 'tbody tr[id^=assignment_]', count: 1
    assert_dom 'tbody a', text: /hidden project/, count: 0
    assert_dom 'a[aria-label="Edit profile"]', count: 0
  end

  test 'links to the profile settings on your own page' do
    show_person

    assert_dom 'a[aria-label="Edit profile"][href=?]', settings_profile_path
  end

  test 'sorts by client by default and remembers the chosen sort' do
    assign('Zeta', 'Alpha')
    assign('Beta', 'Omega')
    assign('Beta', 'Gamma')

    show_person

    assert_equal %w[Gamma Omega Alpha], project_names

    show_person(sort: 'project_desc')

    assert_equal %w[Omega Gamma Alpha], project_names

    show_person

    assert_equal %w[Omega Gamma Alpha], project_names
  end

  test 'shows the client name only on the first row of each client when sorted by client' do
    assign('Beta', 'Omega')
    assign('Beta', 'Gamma')

    show_person

    assert_dom 'tbody tr[id^=assignment_] a', text: 'Beta', count: 1

    show_person(sort: 'project_asc')

    assert_dom 'tbody tr[id^=assignment_] a', text: 'Beta', count: 2
  end

  private

  def assign(client, name, user: @user, **)
    create(:assignment, user:, project: project(client, name), **)
  end

  def project(client, name)
    client = @company.clients.find_by(name: client) || create(:client, company: @company, name: client)
    create(:project, client:, name:)
  end

  def project_names
    css_select('tbody tr[id^=assignment_] a[href^="/projects/"]').map { it.text.strip }
  end

  def show_person(person = @user, **params)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email) do
      get person_path(person, **params)
    end

    assert_response :ok
  end
end
