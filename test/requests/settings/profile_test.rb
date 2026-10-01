# frozen_string_literal: true

require 'test_helper'

module Settings
  class ProfileSignedOutTest < ActionDispatch::IntegrationTest
    test 'redirects to the sign in page' do
      get settings_profile_path

      assert_redirected_to auth_sign_in_path
    end
  end

  class ProfileTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      passwordless_sign_in @user
    end

    test 'renders the profile' do
      get settings_profile_path

      assert_template :show
    end

    test "updates the signed in user's profile" do
      new_name = Faker::Name.name

      patch settings_profile_path, params: { user: { name: new_name } }

      assert_equal new_name, @user.reload.name
    end

    test 'sets an avatar image if none is set' do
      assert_not @user.avatar.attached?

      patch settings_profile_path, params: { user: { avatar: fixture_file_upload('avatar.jpg', 'image/jpg') } }

      assert_predicate @user.reload.avatar, :attached?
    end

    test 'replaces an existing avatar image' do
      @user.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))

      assert_equal 'avatar.jpg', @user.avatar.filename.to_s

      patch settings_profile_path, params: { user: { avatar: fixture_file_upload('whatever.jpg', 'image/jpg') } }

      assert_predicate @user.reload.avatar, :attached?
      assert_equal 'whatever.jpg', @user.avatar.filename.to_s
    end
  end
end
