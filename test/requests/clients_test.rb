# frozen_string_literal: true

require 'test_helper'

class ClientsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @client = create(:client, company: @company, name: 'Acme')
    passwordless_sign_in @user
  end

  test 'renames the client and returns to its projects' do
    rename @client, ' Acme Corp '

    assert_redirected_to projects_path(client: @client.id)
    assert_equal 'Acme Corp', @client.reload.name
  end

  test 'allows changing only the case of the name' do
    rename @client, 'ACME'

    assert_equal 'ACME', @client.reload.name
  end

  test 'rejects a blank or taken name and shows the form again' do
    create(:client, company: @company, name: 'Globex')

    rename @client, ' '

    assert_response :unprocessable_content
    assert_match 'turbo-stream action="replace" target="client_header"', response.body
    assert_match 'Client is required', response.body

    rename @client, 'globex'

    assert_match 'This client name is already taken. Please enter a different name.', response.body
    assert_match 'value="globex"', response.body
    assert_equal 'Acme', @client.reload.name
  end

  test 'clients from other companies are not found' do
    other = create(:client, name: 'Elsewhere')

    rename other, 'Mine now'

    assert_response :not_found
    assert_equal 'Elsewhere', other.reload.name
  end

  private

  def rename(client, name)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email) { patch client_path(client), params: { client: { name: } } }
  end
end
