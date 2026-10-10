# frozen_string_literal: true

module People
  class DeactivatedToggleComponent < ViewComponent::Base
    attr_reader :count, :shown

    def initialize(count:, shown:)
      @count = count
      @shown = shown
    end

    def label
      "#{shown ? 'Hide' : 'Show'} #{count} deactivated #{'person'.pluralize(count)}"
    end

    def render?
      count.positive?
    end

    def toggle_path
      query = request.query_parameters.except('show_deactivated')
      query['show_deactivated'] = '1' unless shown
      query.empty? ? request.path : "#{request.path}?#{query.to_query}"
    end
  end
end
