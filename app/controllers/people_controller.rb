# frozen_string_literal: true

class PeopleController < RailsUiController
  def index; end

  def show
    @user = current_company.users.find(params[:id])
  end
end
