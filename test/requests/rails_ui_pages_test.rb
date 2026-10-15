# frozen_string_literal: true

require 'test_helper'

class RailsUiPagesTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    passwordless_sign_in @user
  end

  test 'pages render in the Rails UI shell' do
    project = create(:project, client: create(:client, company: @user.current_company))

    [people_path, person_path(@user), projects_path, project_path(project)].each do |path|
      get path

      assert_response :ok
      assert_dom 'nav[aria-label=Main]'
      assert_dom 'footer'
    end
  end

  test 'nav links point at the Rails UI' do
    get settings_profile_path

    assert_dom "a[href='/people/#{@user.id}']", text: 'My StaffPlan'
    assert_dom "a[href='/people']", text: 'People'
    assert_dom "a[href='/projects']", text: 'Projects'
    assert_dom 'button[aria-label="New project"]'
  end

  test 'people and projects from other companies are not found' do
    other_user = create(:membership).user
    other_project = create(:project)

    get person_path(other_user)

    assert_response :not_found

    get project_path(other_project)

    assert_response :not_found
  end
end
