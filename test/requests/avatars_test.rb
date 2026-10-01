# frozen_string_literal: true

require 'test_helper'

class AvatarsSignedOutTest < ActionDispatch::IntegrationTest
  test 'redirects to the sign in page' do
    delete avatars_path

    assert_redirected_to auth_sign_in_path
  end
end

class AvatarsTest < ActionDispatch::IntegrationTest
  def attach_avatar(record, file = 'avatar.jpg')
    record.update(avatar: fixture_file_upload(file, 'image/jpg'))

    assert_predicate record.avatar, :attached?
  end

  def attachable_params(attachable:, redirect_to:)
    { attachable: { type: attachable.class.name, id: attachable.id, redirect_to: redirect_to } }
  end

  setup do
    @user = create(:user)
    passwordless_sign_in @user
  end

  test "handles an attachable that's not found" do
    delete avatars_path(attachable: { type: 'Company', id: 0, redirect_to: settings_company_path })

    assert_redirected_to settings_company_path
    assert_equal "Sorry, you can't remove that attachment.", flash[:error]
  end

  test "allows anyone in the company to delete a client's avatar" do
    client = create(:client, company: @user.current_company)
    member = create(:membership, company: @user.current_company, role: Membership::MEMBER).user
    passwordless_sign_in member
    attach_avatar(client)

    delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_equal 'Custom avatar deleted successfully.', flash[:success]
    assert_not client.reload.avatar.attached?
  end

  test "deletes a client's avatar and redirects back" do
    client = create(:client, company: @user.current_company)
    attach_avatar(client)

    delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_not client.reload.avatar.attached?
  end

  test 'does nothing if the client has no avatar attached' do
    client = create(:client, company: @user.current_company)

    assert_not client.avatar.attached?

    delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_not client.reload.avatar.attached?
  end

  test 'does not allow a member who is not an admin or owner to delete the company avatar' do
    company = @user.current_company
    member = create(:membership, company:, role: Membership::MEMBER).user
    passwordless_sign_in member
    attach_avatar(company)

    delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_equal "Sorry, you can't remove that attachment.", flash[:error]
    assert_predicate company.reload.avatar, :attached?
  end

  test "does not allow another company's avatar to be deleted" do
    another_company = create(:company)
    attach_avatar(another_company)

    delete avatars_path(attachable_params(attachable: another_company, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_equal "Sorry, you can't remove that attachment.", flash[:error]
    assert_predicate another_company.reload.avatar, :attached?
  end

  test "deletes the company's avatar and redirects back" do
    company = @user.current_company
    attach_avatar(company)

    delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_not company.reload.avatar.attached?
  end

  test 'does nothing if the company has no avatar attached' do
    company = @user.current_company

    assert_not company.avatar.attached?

    delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))

    assert_redirected_to settings_path
    assert_not company.reload.avatar.attached?
  end

  test "does not allow another user's avatar to be deleted" do
    another_user = create(:user)
    attach_avatar(another_user)

    delete avatars_path(attachable_params(attachable: another_user, redirect_to: settings_profile_path))

    assert_redirected_to settings_profile_path
    assert_equal "Sorry, you can't remove that attachment.", flash[:error]
    assert_predicate another_user.reload.avatar, :attached?
  end

  test "deletes the signed in user's avatar and redirects back to the profile" do
    attach_avatar(@user)

    delete avatars_path(attachable_params(attachable: @user, redirect_to: settings_profile_path))

    assert_redirected_to settings_profile_path
    assert_not @user.reload.avatar.attached?
  end

  test 'does nothing if the user has no avatar attached' do
    assert_not @user.avatar.attached?

    delete avatars_path(attachable_params(attachable: @user, redirect_to: settings_profile_path))

    assert_redirected_to settings_profile_path
    assert_not @user.reload.avatar.attached?
  end
end
