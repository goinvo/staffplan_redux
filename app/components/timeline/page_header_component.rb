# frozen_string_literal: true

module Timeline
  class PageHeaderComponent < ViewComponent::Base
    attr_reader :title, :avatar_url, :inactive

    def initialize(title:, avatar_url: nil, inactive: false)
      @title = title
      @avatar_url = avatar_url
      @inactive = inactive
    end
  end
end
