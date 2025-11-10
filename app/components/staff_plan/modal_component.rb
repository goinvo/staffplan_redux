# frozen_string_literal: true

module StaffPlan
  class ModalComponent < ViewComponent::Base
    def initialize(title: nil, show: false)
      @title = title
      @show = show
    end
  end
end
