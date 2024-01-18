module Settings
  module Users
    class ListItemComponent < ViewComponent::Base
      def initialize(current_company:, user:)
        @current_company = current_company
        @user = user
      end

      def user_name
        @user.name
      end

      def user_email
        @user.email
      end

      def user_status
        current_company_membership.status
      end

      def user_role
        @user.role
      end

      def user_job_title
        # TODO: add a field for users to set this.
        ""
      end

      private

      def current_company_membership
        return @_membership if defined?(@_membership)

        @_membership = @user.memberships.where(company: @current_company).first
      end
    end
  end
end