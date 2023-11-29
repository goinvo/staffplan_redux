# frozen_string_literal: true

class WorkWeekComponent < ViewComponent::Base
  def initialize(work_week:)
    @work_week = work_week
  end

end
