# frozen_string_literal: true

module Timeline
  class GridComponent < ViewComponent::Base
    DEFAULT_VISIBLE_WEEKS = 6

    renders_one :page_header
    renders_one :columns
    renders_one :summary

    attr_reader :window, :hours

    def initialize(window:, hours:)
      @window = window
      @hours = hours
    end

    def controller_data
      {
        controller: 'timeline work-weeks',
        action: [
          'keydown@window->timeline#page touchstart@window->timeline#touchStart touchend@window->timeline#touchEnd turbo:morph@document->timeline#relayout',
          'submit->work-weeks#submit focusin->work-weeks#focus focusout->work-weeks#blur keydown->work-weeks#keydown input->work-weeks#input',
        ].join(' '),
        timeline_start_value: window.start.iso8601,
        timeline_current_week_value: window.current_week_index || -1,
      }
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

    private

    def start_path(date)
      "#{request.path}?#{request.query_parameters.merge('start' => date.iso8601).to_query}"
    end
  end
end
