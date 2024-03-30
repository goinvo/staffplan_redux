require 'rails_helper'

RSpec.describe "Avatars", type: :request do

  def attachable_params(attachable:, redirect_to:)
    { attachable: { type: attachable.class.name, id: attachable.id, redirect_to: redirect_to } }
  end

  context "when no use is logged in" do
    describe "DELETE /avatars" do
      it "redirects to the login page" do
        delete avatars_path
        expect(response).to redirect_to(auth_sign_in_path)
      end
    end
  end

  context "when logged in" do
    before do
      @user = FactoryBot.create(:user)
      passwordless_sign_in @user
    end

    context "managing avatars" do
      it "handles an attachable that's not found" do
        delete avatars_path(attachable: { type: 'Company', id: 0, redirect_to: settings_path })
        expect(response).to redirect_to(settings_path)
        expect(flash[:error]).to eq("Sorry, you can't remove that attachment.")
      end
    end

    context "managing client avatars" do
      describe "DELETE /avatars" do
        it "allows anyone in the company to manage the client's avatar" do
          client = create(:client, company: @user.current_company)
          member = create(:membership, company: @user.current_company, role: 'member').user
          passwordless_sign_in member

          client.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(client.avatar).to be_attached

          delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

          expect(response).to redirect_to(settings_path)
          expect(flash[:success]).to eq("Custom avatar deleted successfully.")
          expect(client.reload.avatar).to_not be_attached
        end

        it "deletes the avatar and redirects back to the settings page" do
          client = create(:client, company: @user.current_company)
          client.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(client.avatar).to be_attached

          delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

          expect(response).to redirect_to(settings_path)
          expect(client.reload.avatar).to_not be_attached
        end

        it "does nothing if the client has no avatar attached" do
          client = create(:client, company: @user.current_company)
          expect(client.avatar).to_not be_attached

          delete avatars_path(attachable_params(attachable: client, redirect_to: settings_path))

          expect(response).to redirect_to(settings_path)
          expect(client.reload.avatar).to_not be_attached
        end
      end
    end

    context "managing company avatars" do
      describe "DELETE /avatars" do
        it "does not allow a non-admin or owner to delete the company avatar" do
          company = @user.current_company
          member = create(:membership, company: company, role: 'member').user
          passwordless_sign_in member

          company.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(company.avatar).to be_attached

          delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))

          expect(response).to redirect_to(settings_path)
          expect(flash[:error]).to eq("Sorry, you can't remove that attachment.")
          expect(company.reload.avatar).to be_attached
        end

        it "does not allow another company's avatar to be deleted" do
          another_company = create(:company)
          another_company.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(another_company.avatar).to be_attached

          delete avatars_path(attachable_params(attachable: another_company, redirect_to: settings_path))

          expect(response).to redirect_to(settings_path)
          expect(flash[:error]).to eq("Sorry, you can't remove that attachment.")
          expect(another_company.reload.avatar).to be_attached
        end

        it "deletes the avatar and redirects back to the settings page" do
          company = @user.current_company
          company.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(company.avatar).to be_attached
          delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))
          expect(response).to redirect_to(settings_path)
          expect(company.reload.avatar).to_not be_attached
        end

        it "does nothing if the company has no avatar attached" do
          company = @user.current_company
          expect(company.avatar).to_not be_attached
          delete avatars_path(attachable_params(attachable: company, redirect_to: settings_path))
          expect(response).to redirect_to(settings_path)
          expect(company.reload.avatar).to_not be_attached
        end
      end
    end

    context "managing user avatars" do
      describe "DELETE /avatars" do
        it "does not allow another user's avatar to be deleted" do
          another_user = create(:user)
          another_user.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(another_user.avatar).to be_attached
          delete avatars_path(attachable_params(attachable: another_user, redirect_to: users_profile_path))
          expect(response).to redirect_to(users_profile_path)
          expect(flash[:error]).to eq("Sorry, you can't remove that attachment.")
          expect(another_user.reload.avatar).to be_attached
        end

        it "deletes the avatar and redirects back to the user profile" do
          @user.update(avatar: fixture_file_upload('avatar.jpg', 'image/jpg'))
          expect(@user.avatar).to be_attached
          delete avatars_path(attachable_params(attachable: @user, redirect_to: users_profile_path))
          expect(response).to redirect_to(users_profile_path)
          expect(@user.reload.avatar).to_not be_attached
        end

        it "does nothing if the user has no avatar attached" do
          expect(@user.avatar).to_not be_attached
          delete avatars_path(attachable_params(attachable: @user, redirect_to: users_profile_path))
          expect(response).to redirect_to(users_profile_path)
          expect(@user.reload.avatar).to_not be_attached
        end
      end
    end
  end
end
