module Shared
  class StatusComponent < ViewComponent::Base
    def initialize(status:)
      @status = status
    end

    def target_status
      @status.capitalize
    end

    def target_status_color
      case @status
      when Membership::ACTIVE || Client::ACTIVE
        "bg-green-50 text-green-700 ring-green-600/20"
      else
        "bg-gray-50 text-gray-600 ring-gray-500/10"
      end
    end
  end
end