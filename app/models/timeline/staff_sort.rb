# frozen_string_literal: true

module Timeline
  class StaffSort
    DIRECTIONS = %w[asc desc].freeze

    attr_reader :direction

    def self.parse(value)
      new(value.to_s.delete_prefix('people_').presence_in(DIRECTIONS) || 'asc')
    end

    def initialize(direction)
      @direction = direction
    end

    def apply(assignments)
      unassigned, assigned = assignments.partition { it.user.nil? }
      sorted = assigned.sort_by { it.user.name.downcase }
      unassigned.sort_by(&:id) + (desc? ? sorted.reverse : sorted)
    end

    def column = 'people'

    def desc? = direction == 'desc'

    def next_for(_column) = desc? ? 'people_asc' : 'people_desc'

    def to_param = "people_#{direction}"
  end
end
