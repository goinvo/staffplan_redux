# frozen_string_literal: true

module Timeline
  class AssignmentSort
    COLUMNS = %w[client project].freeze
    DIRECTIONS = %w[asc desc].freeze

    attr_reader :column, :direction

    def self.parse(value)
      column, direction = value.to_s.split('_', 2)
      return new unless COLUMNS.include?(column) && DIRECTIONS.include?(direction)

      new(column:, direction:)
    end

    def initialize(column: 'client', direction: 'asc')
      @column = column
      @direction = direction
    end

    def apply(assignments)
      case column
      when 'project'
        sorted = assignments.sort_by { project_name(it) }
        desc? ? sorted.reverse : sorted
      when 'client'
        assignments.sort do |a, b|
          clients = client_name(a) <=> client_name(b)
          clients = -clients if desc?
          clients.zero? ? project_name(a) <=> project_name(b) : clients
        end
      end
    end

    def by_client? = column == 'client'

    def desc? = direction == 'desc'

    def next_for(column)
      direction = column == self.column && !desc? ? 'desc' : 'asc'
      "#{column}_#{direction}"
    end

    def to_param = "#{column}_#{direction}"

    private

    def client_name(assignment) = assignment.project.client.name.downcase

    def project_name(assignment) = assignment.project.name.downcase
  end
end
