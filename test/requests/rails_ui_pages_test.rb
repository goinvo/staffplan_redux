# frozen_string_literal: true

require 'test_helper'

class RailsUiPagesTest < ActionDispatch::IntegrationTest
  REACT_UI_URL = 'https://ui.example.test'

  setup do
    @user = create(:membership).user
    passwordless_sign_in @user
  end

  test 'pages render in the Rails UI shell for allowlisted users' do
    project = create(:project, client: create(:client, company: @user.current_company))

    rails_ui(emails: @user.email) do
      [people_path, person_path(@user), projects_path, project_path(project)].each do |path|
        get path

        assert_response :ok
        assert_dom 'nav[aria-label=Main]'
        assert_dom 'footer'
      end
    end
  end

  test 'pages redirect to the React app for everyone else' do
    rails_ui do
      get person_path(@user)
    end

    assert_redirected_to "#{REACT_UI_URL}/people/#{@user.id}"
  end

  test 'people and projects from other companies are not found' do
    other_user = create(:membership).user
    other_project = create(:project)

    rails_ui(emails: @user.email) do
      get person_path(other_user)

      assert_response :not_found

      get project_path(other_project)

      assert_response :not_found
    end
  end

  private

  def rails_ui(emails: '', &)
    with_config(react_ui_url: REACT_UI_URL, rails_ui_enabled: '', rails_ui_emails: emails, &)
  end
end
