# frozen_string_literal: true

module Timeline
  class UndoTemplateComponent < ViewComponent::Base
    attr_reader :name, :title, :subtitle

    def initialize(name:, title:, subtitle: nil)
      @name = name
      @title = title
      @subtitle = subtitle
    end
  end
end
