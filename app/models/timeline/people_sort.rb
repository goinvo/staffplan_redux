# frozen_string_literal: true

module Timeline
  class PeopleSort
    MODES = %w[least_covered most_covered alpha_asc alpha_desc].freeze
    LABELS = { 'least_covered' => 'least covered', 'most_covered' => 'most covered', 'alpha_asc' => 'alpha', 'alpha_desc' => 'alpha' }.freeze

    attr_reader :mode

    def self.future_hours(assignments, today: Time.zone.today)
      assignments.joins(:work_weeks)
        .merge(WorkWeek.from_week_of(today))
        .group(:user_id)
        .sum('work_weeks.estimated_hours')
    end

    def self.parse(value)
      new(MODES.include?(value) ? value : MODES.first)
    end

    def initialize(mode)
      @mode = mode
    end

    def apply(people, assignments:)
      case mode
      when 'alpha_asc' then people.sort_by { it.name.downcase }
      when 'alpha_desc' then people.sort_by { it.name.downcase }.reverse
      else
        hours = self.class.future_hours(assignments)
        direction = mode == 'most_covered' ? -1 : 1
        people.sort_by { [direction * hours.fetch(it.id, 0), it.name.downcase] }
      end
    end

    def desc? = mode.in?(%w[most_covered alpha_desc])

    def label = LABELS.fetch(mode)

    def next = MODES[(MODES.index(mode) + 1) % MODES.size]

    def to_param = mode
  end
end
