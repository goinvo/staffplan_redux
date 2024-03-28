require 'rails_helper'

RSpec.describe "User Profile", type: :request do
  context "when no use is logged in" do
    describe "GET /users/profile" do
      it "redirects to the login page" do
        get users_profile_path
        expect(response).to redirect_to(auth_sign_in_path)
      end
    end
  end

  context "when logged in as a user" do
    before do
      @user = FactoryBot.create(:user)
      passwordless_sign_in @user
    end

    describe "GET /users/profile" do
      it "renders the show template" do
        get users_profile_path
        expect(response).to render_template(:show)
      end
    end

    describe "PATCH /users/profile" do
      it "updates the currently signed in user's profile" do
        patch users_profile_path, params: { user: { name: new_name = Faker::Name.name } }
        expect(@user.reload.name).to eq(new_name)
      end

      it "will set an avatar image if none is set" do
        expect(@user.avatar).to_not be_attached
        patch users_profile_path, params: { user: { avatar: fixture_file_upload('avatar.jpg', 'image/jpg') } }
        expect(@user.reload.avatar).to be_attached
      end

      it "will replace an existing avatar image" do
        @user.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
        expect(@user.avatar).to be_attached
        expect(@user.avatar.filename).to eq('avatar.jpg')

        patch users_profile_path, params: { user: { avatar: fixture_file_upload('whatever.jpg', 'image/jpg') } }

        expect(@user.reload.avatar).to be_attached
        expect(@user.avatar.filename).to eq('whatever.jpg')
      end
    end
  end
end
