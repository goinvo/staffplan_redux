# frozen_string_literal: true

module Timeline
  class RevealToggleComponent < ViewComponent::Base
    attr_reader :count, :shown, :noun, :param

    def initialize(count:, shown:, noun:, param:)
      @count = count
      @shown = shown
      @noun = noun
      @param = param
    end

    def label
      "#{shown ? 'Hide' : 'Show'} #{count} #{noun.pluralize(count)}"
    end

    def render?
      count.positive?
    end

    def toggle_path
      query = request.query_parameters.except(param)
      query[param] = '1' unless shown
      query.empty? ? request.path : "#{request.path}?#{query.to_query}"
    end
  end
end
