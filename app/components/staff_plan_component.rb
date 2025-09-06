# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end
  attr_reader :user

  def react_staffplan_url
    case Rails.env
    when 'production'
      "https://ui.staffplan.com/people/#{helpers.current_user.id}"
    else
      "http://localhost:8080/people/#{helpers.current_user.id}"
    end
  end
end
