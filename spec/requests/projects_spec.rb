require 'rails_helper'

RSpec.describe "Projects", type: :request do
  context "when no use is logged in" do
    describe "GET /projects" do
      it "redirects to the login page" do
        get projects_path
        expect(response).to redirect_to(auth_sign_in_path)
      end
    end
  end

  context "when logged in as a user" do
    before do
      @user = FactoryBot.create(:user)
      passwordless_sign_in @user
    end

    describe "GET /projects" do
      it "renders the index template" do
        get projects_path
        expect(response).to render_template(:index)
      end
    end

    describe "GET /projects/:id" do
      it "renders the show template" do
        project = FactoryBot.create(:project)
        get project_path(project)
        expect(response).to render_template(:show)
      end

      it "returns a 404 for a project that doesn't exist" do
        get project_path(123)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /projects/new" do
      it "renders the new template" do
        get new_project_path
        expect(response).to render_template(:new)
      end

      it "sets the client_id on the new project if passed in" do
        client = FactoryBot.create(:client)
        get new_project_path(client_id: client.id)
        expect(assigns(:project).client_id).to eq(client.id)
      end

      it "sets the status to unconfirmed on the new project" do
        get new_project_path
        expect(assigns(:project).status).to eq("unconfirmed")
      end

      it "sets the payment_frequency to monthly on the new project" do
        get new_project_path
        expect(assigns(:project).payment_frequency).to eq("monthly")
      end
    end

    describe "GET /projects/:id/edit" do
      it "renders the edit template" do
        project = FactoryBot.create(:project)
        get edit_project_path(project)
        expect(response).to render_template(:edit)
      end

      it "returns a 404 for a project that doesn't exist" do
        get edit_project_path(123)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "POST /projects" do
      it "creates a project" do
        client = FactoryBot.create(:client)
        project_params = FactoryBot.attributes_for(:project, client_id: client.id)
        expect {
          post projects_path, params: { project: project_params }
        }.to change(Project, :count).by(1)
      end

      it "redirects to the project page" do
        client = FactoryBot.create(:client)
        project_params = FactoryBot.attributes_for(:project, client_id: client.id)
        post projects_path, params: { project: project_params }
        expect(response).to redirect_to(project_path(Project.last))
      end

      it "returns a 422 for invalid params" do
        project_params = FactoryBot.attributes_for(:project, name: nil)
        post projects_path, params: { project: project_params }
        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /projects/:id" do
      it "updates a project" do
        project = FactoryBot.create(:project)
        project_params = FactoryBot.attributes_for(:project, name: "New Name")
        patch project_path(project), params: { project: project_params }
        expect(project.reload.name).to eq("New Name")
      end

      it "redirects to the project page" do
        project = FactoryBot.create(:project)
        project_params = FactoryBot.attributes_for(:project, name: "New Name")
        patch project_path(project), params: { project: project_params }
        expect(response).to redirect_to(project_path(project))
      end

      it "returns a 422 for invalid params" do
        project = FactoryBot.create(:project)
        project_params = FactoryBot.attributes_for(:project, name: nil)
        patch project_path(project), params: { project: project_params }
        expect(response).to have_http_status(422)
      end
    end
  end
end
