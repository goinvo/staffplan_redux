# frozen_string_literal: true

class RailsUiController < ApplicationController
  before_action :require_user!
  before_action :require_rails_ui!

  layout 'rails_ui'
end
