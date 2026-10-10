# frozen_string_literal: true

module People
  class PersonRowComponent < ViewComponent::Base
    attr_reader :user, :hours, :deactivated

    def initialize(user:, hours:, deactivated: false)
      @user = user
      @hours = hours
      @deactivated = deactivated
    end

    def avatar_url
      AvatarHelper.new(target: user).image_url
    end
  end
end
