# frozen_string_literal: true

module Projects
  class ProjectRowComponent < ViewComponent::Base
    attr_reader :project, :sort, :client_view, :hours, :summary

    def initialize(project:, previous:, last:, sort:, client_view:, hours:, summary:, viewer:, highlight: false) # rubocop:disable Metrics/ParameterLists
      @project = project
      @previous = previous
      @last = last
      @sort = sort
      @client_view = client_view
      @hours = hours
      @summary = summary
      @viewer = viewer
      @highlight = highlight
    end

    def client_label?
      !sort.by_client? || new_client?
    end

    def hidden_assignment
      hours.assignments.find { it.user_id == @viewer.id && !it.focused }
    end

    def row_class
      [
        'pl-5 flex sm:justify-normal justify-between border-gray-300 hover:bg-hoverGrey',
        ('border-t' if @previous && client_label?),
        ('border-b' if @last),
        ('animate-fade-in-scale' if @highlight),
      ]
    end

    def summary_class(item)
      case item[:label]
      when 'Target' then 'border-b border-contrastGrey/20'
      when 'Delta' then 'border-t border-contrastGrey/20'
      end
    end

    def summary_value(item)
      item[:value].is_a?(Numeric) ? helpers.number_with_delimiter(item[:value]) : item[:value]
    end

    private

    def new_client?
      @previous.nil? || @previous.client_id != project.client_id
    end
  end
end
