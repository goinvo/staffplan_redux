# frozen_string_literal: true

module Timeline
  class PageHeaderComponent < ViewComponent::Base
    attr_reader :title, :avatar_url, :inactive, :edit_path

    def initialize(title:, avatar_url: nil, inactive: false, edit_path: nil)
      @title = title
      @avatar_url = avatar_url
      @inactive = inactive
      @edit_path = edit_path
    end
  end
end
