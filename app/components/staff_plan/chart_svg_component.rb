# frozen_string_literal: true

module StaffPlan
  class ChartSvgComponent < ViewComponent::Base
    def initialize(work_weeks:, max_value: 50)
      @work_weeks = Array(work_weeks)
      @max_value = max_value
    end

    attr_reader :work_weeks, :max_value

    def format_hours
      return 0 if should_not_render_any_hours?

      total_hours.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def has_actual_hours?
      work_weeks.any? { |ww| ww.actual_hours&.positive? }
    end

    def is_before_week?
      return false if work_weeks.empty?

      # Get the first work week to determine the week we're checking
      first_week = work_weeks.first
      return false unless first_week.year && first_week.cweek

      today = Time.zone.today
      # Treat current week as past week (use >= instead of >)
      today.cwyear > first_week.year ||
        (today.cwyear == first_week.year && today.cweek >= first_week.cweek)
    end

    def main_path_color
      has_actual_hours? || is_before_week? ? '#AEB3C0' : '#27B5B0'
    end

    def proposed_fill_color
      is_before_week? ? '#AEB3C0' : '#79e3e0'
    end

    def proposed_hours
      @proposed_hours ||= work_weeks
        .select { |ww| ww.assignment&.status == Assignment::PROPOSED }
        .sum { |ww| is_before_week? ? ww.actual_hours : ww.estimated_hours }
    end

    def proposed_svg_height
      @proposed_svg_height ||= begin
        validated_height = [0, [proposed_hours, max_value].min].max
        scale = 100.0 / (max_value + 30)
        validated_height * scale
      end
    end

    def should_not_render_any_hours?
      !has_actual_hours? && is_before_week?
    end

    def should_render_estimated_with_proposed_path?
      !has_actual_hours? && proposed_svg_height.positive? && proposed_hours < total_hours
    end

    def should_render_only_proposed_path?
      !has_actual_hours? && proposed_hours >= total_hours
    end

    def should_render_svg?
      total_hours.positive? && !should_not_render_any_hours?
    end

    def svg_height
      @svg_height ||= begin
        validated_height = [0, [total_hours, max_value].min].max
        scale = 100.0 / (max_value + 30)
        validated_height * scale
      end
    end

    def total_hours
      @total_hours ||= if has_actual_hours? || is_before_week?
                         work_weeks.sum(&:actual_hours)
                       else
                         work_weeks.sum(&:estimated_hours)
                       end
    end
  end
end
