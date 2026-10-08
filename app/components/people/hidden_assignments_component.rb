# frozen_string_literal: true

module People
  class HiddenAssignmentsComponent < ViewComponent::Base
    attr_reader :count, :hours, :window, :show_hidden

    def initialize(count:, hours:, window:, show_hidden:)
      @count = count
      @hours = hours
      @window = window
      @show_hidden = show_hidden
    end

    def label
      show_hidden ? "Ok, only show projects I'm interested in" : "Show #{count} hidden #{'project'.pluralize(count)}"
    end

    def render?
      count.positive?
    end

    def toggle_path
      query = request.query_parameters.except('show_hidden')
      query['show_hidden'] = '1' unless show_hidden
      query.empty? ? request.path : "#{request.path}?#{query.to_query}"
    end

    def totals
      { 'Plan' => :estimated, 'Actual' => :actual }
    end
  end
end
