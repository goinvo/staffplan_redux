require 'rails_helper'

RSpec.describe "Avatars", type: :request do
  context "when no use is logged in" do
    describe "DELETE /avatars" do
      it "redirects to the login page" do
        delete avatars_path
        expect(response).to redirect_to(auth_sign_in_path)
      end
    end
  end

  context "when logged in as a user" do
    before do
      @user = FactoryBot.create(:user)
      passwordless_sign_in @user
    end

    describe "DELETE /avatars" do
      it "deletes the avatar and redirects back to the user profile" do
        @user.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
        expect(@user.avatar).to be_attached
        delete avatars_path
        expect(response).to redirect_to(users_profile_path)
        expect(@user.reload.avatar).to_not be_attached
      end

      it "does nothing if the user has no avatar attached" do
        expect(@user.avatar).to_not be_attached
        delete avatars_path
        expect(response).to redirect_to(users_profile_path)
        expect(@user.reload.avatar).to_not be_attached
      end
    end
  end
end
