# frozen_string_literal: true

module Timeline
  class Window
    WEEK_COUNT = 52
    YEARS = 2000..2199

    Week = Data.define(:index, :monday, :this_monday) do
      delegate :cweek, to: :monday

      def current? = monday == this_monday

      def past? = monday < this_monday

      def year = monday.cwyear
    end

    def self.from_param(value, today: Time.zone.today)
      new(start: parse(value) || (today.beginning_of_week(:monday) - 1.week), today:)
    end

    def self.parse(value)
      date = Date.iso8601(value.to_s)
      date if YEARS.cover?(date.year)
    rescue Date::Error
      nil
    end
    private_class_method :parse

    attr_reader :start, :today

    def initialize(start:, today: Time.zone.today)
      @start = start.beginning_of_week(:monday)
      @today = today
    end

    def current_week_index
      weeks.find(&:current?)&.index
    end

    def shift(count)
      start + count.weeks
    end

    def weeks
      @weeks ||= Array.new(WEEK_COUNT) do |index|
        Week.new(index:, monday: start + index.weeks, this_monday: today.beginning_of_week(:monday))
      end
    end
  end
end
