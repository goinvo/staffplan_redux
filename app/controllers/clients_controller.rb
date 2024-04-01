class ClientsController < ApplicationController
  before_action :require_user!
  before_action :set_client, only: %i[ show edit update toggle_archived ]

  def index
    @clients = current_company.clients.all
  end

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = current_company.clients.new(create_client_params)

    if @client.save
      redirect_to client_url(@client), notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(update_client_params)
      redirect_to client_url(@client), notice: "Client was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_archived
    @client.toggle_archived!

    redirect_to clients_url, notice: "Client status was successfully updated."
  end

  private
    def set_client
      @client = current_company.clients.find(params[:id])
    end

    def create_client_params
      params.require(:client).permit(:name, :description)
    end

    def update_client_params
      params.require(:client).permit(:name, :description, :status, :avatar)
    end
end
