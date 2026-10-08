# frozen_string_literal: true

module Timeline
  class WeekHeaderCellComponent < ViewComponent::Base
    attr_reader :week

    def initialize(week:)
      @week = week
    end

    def date_range
      "#{monday.strftime('%d.%b')} to #{(monday + 6.days).strftime('%d.%b')}"
    end

    def label
      if monday.day <= 7
        monday.strftime('%b')
      elsif monday.month == 1 && monday.day <= 14
        monday.year.to_s
      end
    end

    private

    def monday = week.monday
  end
end
