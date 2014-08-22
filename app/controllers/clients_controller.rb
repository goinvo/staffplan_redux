class ClientsController < ApplicationController
  def index
    @clients = current_user.current_company.clients
  end

  def show
    @client = current_user.current_company.clients.find(params[:id])
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      flash[:notice] = "Your client was created successfully"
      redirect_to client_path(@client)
    else
      flash.now[:notice] = "Couldn't create your client"
      render :new
    end
  end

  def edit
    @client = current_user.current_company.clients.find(params[:id])
  end

  def update
    @client = current_user.current_company.clients.find(params[:id])

    if @client.update(client_params)
      flash[:notice] = "Your client was updated successfully"
      redirect_to client_path(@client)
    else
      flash.now[:notice] = "Couldn't update your client"
      render :edit
    end
  end

  def destroy
    @client = current_user.current_company.clients.find(params[:id])

    @client.destroy
    flash[:notice] = "Your client was deleted"
    redirect_to clients_path
  end

  private

  def client_params
    params.require(:client).permit(:name, :description)
  end
end
