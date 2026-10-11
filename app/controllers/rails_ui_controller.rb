# frozen_string_literal: true

class RailsUiController < ApplicationController
  before_action :require_user!
  before_action :require_rails_ui!

  layout 'rails_ui'

  helper_method :manager?

  private

  def manager?
    current_user.role(company: current_company).in?([Membership::OWNER, Membership::ADMIN])
  end

  def remembered_sort(sort_class, cookie)
    return sort_class.parse(cookies[cookie]) if params[:sort].blank?

    sort = sort_class.parse(params[:sort])
    cookies.permanent[cookie] = sort.to_param
    sort
  end
end
