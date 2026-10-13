# frozen_string_literal: true

module Timeline
  class GridComponent < ViewComponent::Base
    DEFAULT_VISIBLE_WEEKS = 6

    renders_one :page_header
    renders_one :mobile_header
    renders_one :columns
    renders_one :summary

    DATE_MARKER_ACTIONS = 'dragstart->project-dates#start dragover->project-dates#over drop->project-dates#drop dragend->project-dates#end'

    attr_reader :window, :hours, :extra_controller, :project

    def initialize(window:, hours:, extra_controller: nil, project: nil)
      @window = window
      @hours = hours
      @extra_controller = extra_controller
      @project = project
    end

    def controller_data
      {
        controller: ['timeline work-weeks', extra_controller].compact.join(' '),
        action: [
          'keydown@window->timeline#page touchstart@window->timeline#touchStart touchend@window->timeline#touchEnd turbo:morph@document->timeline#relayout',
          'submit->work-weeks#submit focusin->work-weeks#focus focusout->work-weeks#blur keydown->work-weeks#keydown input->work-weeks#input',
        ].join(' '),
        timeline_start_value: window.start.iso8601,
        timeline_current_week_value: window.current_week_index || -1,
      }
    end

    def date_marker(week)
      if week.cover?(project.starts_on)
        'starts_on'
      elsif week.cover?(project.ends_on)
        'ends_on'
      end
    end

    def default_style
      hidden = (DEFAULT_VISIBLE_WEEKS...Window::WEEK_COUNT).map { %(#timeline [data-timeline-week="#{it}"]) }
      "#{hidden.join(',')}{display:none!important}".html_safe # rubocop:disable Rails/OutputSafety
    end

    def next_path
      start_path(window.shift(DEFAULT_VISIBLE_WEEKS))
    end

    def previous_path
      start_path(window.shift(-DEFAULT_VISIBLE_WEEKS))
    end

    def today_path
      query = request.query_parameters.except('start')
      query.empty? ? request.path : "#{request.path}?#{query.to_query}"
    end

    def week_header_options(week)
      options = { class: ['hidden sm:block relative px-1', week.current? ? 'navbar font-bold' : 'font-normal'], data: { timeline_week: week.index } }
      return options unless project

      marker = date_marker(week)
      options.deep_merge(
        draggable: marker.present?,
        class: [*options[:class], ('cursor-pointer' if marker)],
        data: { date: week.monday.iso8601, marker:, action: DATE_MARKER_ACTIONS },
      )
    end

    private

    def start_path(date)
      "#{request.path}?#{request.query_parameters.merge('start' => date.iso8601).to_query}"
    end
  end
end
