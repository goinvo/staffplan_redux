# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(user:, target_date: Time.zone.today)
    @user = user
    @target_date = target_date
  end
  attr_reader :user, :target_date

  def react_staffplan_url
    case Rails.env.to_s
    when 'production'
      "https://ui.staffplan.com/people/#{helpers.current_user.id}"
    else
      "http://localhost:8080/people/#{helpers.current_user.id}"
    end
  end
end
