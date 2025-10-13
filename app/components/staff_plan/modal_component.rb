# frozen_string_literal: true

class StaffPlan::ModalComponent < ViewComponent::Base
  def initialize(title: nil, show: false)
    @title = title
    @show = show
  end
end
