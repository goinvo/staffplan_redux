# frozen_string_literal: true

module Timeline
  class BarChartComponent < ViewComponent::Base
    GREY = '#AEB3C0'
    TEAL = '#27B5B0'
    LIGHT_TEAL = '#79e3e0'

    attr_reader :hours, :max, :past, :text_class

    def initialize(hours:, max:, past:, text_class: 'text-white')
      @hours = hours
      @max = max
      @past = past
      @text_class = text_class
    end

    def bar?
      hours.total.positive? && !hidden?
    end

    def bar_height
      scaled(hours.total)
    end

    def label
      hidden? ? 0 : helpers.number_with_delimiter(hours.total)
    end

    def main_color
      hours.actual? || past ? GREY : TEAL
    end

    def only_proposed?
      !hours.actual? && hours.proposed >= hours.total
    end

    def proposed_color
      past ? GREY : LIGHT_TEAL
    end

    def proposed_height
      scaled(hours.proposed)
    end

    def proposed_segment?
      !hours.actual? && hours.proposed.positive? && !only_proposed?
    end

    private

    def hidden?
      !hours.actual? && past
    end

    def scaled(value)
      (value.clamp(0, max) * 100.0 / (max + 30)).round(2)
    end
  end
end
