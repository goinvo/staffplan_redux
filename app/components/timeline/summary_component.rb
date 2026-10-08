# frozen_string_literal: true

module Timeline
  class SummaryComponent < ViewComponent::Base
    Item = Data.define(:label, :value, :tooltip) do
      def initialize(label:, value:, tooltip: nil) = super
    end

    attr_reader :items

    def initialize(items:)
      @items = items.map { Item.new(**it) }
    end

    def border_class(item)
      case item.label
      when 'Target' then 'border-b border-contrastGrey'
      when 'Delta' then 'border-t border-contrastGrey'
      end
    end

    def render?
      items.any?
    end

    def value(item)
      item.value.is_a?(Numeric) ? helpers.number_with_delimiter(item.value) : item.value
    end
  end
end
