require 'rails_helper'

RSpec.describe "Clients", type: :request do

  context "when user is not logged in" do
    describe "GET /index" do
      it "redirects to login page" do
        get clients_path
        expect(response).to redirect_to("/sign_in")
      end
    end
  end

  context "when user is logged in" do
    before do
      @user = FactoryBot.create(:user)
      passwordless_sign_in(@user)
    end

    describe "GET /index" do
      it "returns http success" do
        get clients_path
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get clients_path
        expect(response).to render_template(:index)
      end

      it "returns all clients" do
        FactoryBot.create(:client, company: @user.current_company)
        FactoryBot.create(:client, company: @user.current_company)
        FactoryBot.create(:client, company: @user.current_company)
        FactoryBot.create(:client, company: @user.current_company)
        get clients_path
        expect(assigns(:clients).length).to eq(4)
      end
    end

    describe "GET /show" do
      it "returns http success" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get client_path(client)
        expect(response).to have_http_status(:success)
      end

      it "renders the show template" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get client_path(client)
        expect(response).to render_template(:show)
      end

      it "returns the correct client" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get client_path(client)
        expect(assigns(:client)).to eq(client)
      end

      it "renders the 404 page if the client does not belong to the current_company" do
        client = FactoryBot.create(:client)
        expect(@user.current_company.clients).not_to include(client)
        get client_path(client.id)
        expect(response.status).to eq(404)
      end
    end

    describe "GET /new" do
      it "returns http success" do
        get new_client_path
        expect(response).to have_http_status(:success)
      end

      it "renders the new template" do
        get new_client_path
        expect(response).to render_template(:new)
      end
    end

    describe "GET /edit" do
      it "returns http success" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get edit_client_path(client)
        expect(response).to have_http_status(:success)
      end

      it "renders the edit template" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get edit_client_path(client)
        expect(response).to render_template(:edit)
      end

      it "returns the correct client" do
        client = FactoryBot.create(:client, company: @user.current_company)
        get edit_client_path(client)
        expect(assigns(:client)).to eq(client)
      end

      it "renders the 404 page if the client does not belong to the current_company" do
        client = FactoryBot.create(:client)
        expect(@user.current_company.clients).not_to include(client)
        get edit_client_path(client.id)
        expect(response.status).to eq(404)
      end
    end

    describe "POST /create" do
      it "creates a new client" do
        expect {
          post clients_path, params: { client: FactoryBot.attributes_for(:client) }
        }.to change(Client, :count).by(1)
      end

      it "redirects to the client page" do
        post clients_path, params: { client: FactoryBot.attributes_for(:client) }
        expect(response).to redirect_to(client_path(Client.last))
      end

      it "returns an error if the client is invalid" do
        post clients_path, params: { client: { name: nil } }
        expect(response).to render_template(:new)
      end

      it "sets the client's company to the current_company" do
        post clients_path, params: { client: FactoryBot.attributes_for(:client) }
        expect(Client.last.company).to eq(@user.current_company)
      end

      it "sets the client's status to active" do
        post clients_path, params: { client: FactoryBot.attributes_for(:client) }
        expect(Client.last.status).to eq(Client::ACTIVE)
      end

      it "returns an error if the client's name is not unique for the current_company" do
        client = FactoryBot.create(:client, company: @user.current_company)
        post clients_path, params: { client: { name: client.name } }
        expect(response).to render_template(:new)
      end
    end

    describe "PATCH /update" do
      it "updates the client" do
        client = FactoryBot.create(:client, company: @user.current_company)
        patch client_path(client), params: { client: { name: "New Name" } }
        expect(client.reload.name).to eq("New Name")
      end

      it "redirects to the client page" do
        client = FactoryBot.create(:client, company: @user.current_company)
        patch client_path(client), params: { client: { name: "New Name" } }
        expect(response).to redirect_to(client_path(client))
      end

      it "returns an error if the client is invalid" do
        client = FactoryBot.create(:client, company: @user.current_company)
        patch client_path(client), params: { client: { name: nil } }
        expect(response).to render_template(:edit)
      end

      it "renders the 404 page if the client does not belong to the current_company" do
        client = FactoryBot.create(:client)
        expect(@user.current_company.clients).not_to include(client)
        patch client_path(client), params: { client: { name: "New Name" } }
        expect(response.status).to eq(404)
      end

      it "returns an error if the client's name is not unique for the current_company" do
        client = FactoryBot.create(:client, company: @user.current_company)
        other_client = FactoryBot.create(:client, company: @user.current_company)
        patch client_path(client), params: { client: { name: other_client.name } }
        expect(response).to render_template(:edit)
      end
    end

    describe "POST /toggle_archived" do
      it "toggles the client's status" do
        client = FactoryBot.create(:client, company: @user.current_company)
        expect(client.confirmed?).to eq(true)
        post toggle_archived_client_path(client)
        expect(client.reload.archived?).to eq(true)
      end

      it "redirects to the clients page" do
        client = FactoryBot.create(:client, company: @user.current_company)
        post toggle_archived_client_path(client)
        expect(response).to redirect_to(clients_path)
      end

      it "renders the 404 page if the client does not belong to the current_company" do
        client = FactoryBot.create(:client)
        expect(@user.current_company.clients).not_to include(client)
        post toggle_archived_client_path(client)
        expect(response.status).to eq(404)
      end
    end
  end
end
