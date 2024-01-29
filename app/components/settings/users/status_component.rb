module Settings
  module Users
    class StatusComponent < ViewComponent::Base
      def initialize(status:)
        @status = status
      end

      def user_status
        @status.capitalize
      end

      def user_status_color
        case @status
        when Membership::ACTIVE
          "bg-green-50 text-green-700 ring-green-600/20"
        else
          "bg-gray-50 text-gray-600 ring-gray-500/10"
        end
      end
    end
  end
end