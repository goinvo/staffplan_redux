# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :require_user!
  def show
    redirect_to settings_profile_url
  end
end
