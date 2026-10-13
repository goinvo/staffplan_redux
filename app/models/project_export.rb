# frozen_string_literal: true

class ProjectExport
  HEADERS = ['Project Name', 'Start Date', 'End Date', 'Work Week', 'Plan Hours', 'Actual Hours', 'Total Hours'].freeze
  DATE = '%d.%m.%Y'

  attr_reader :project

  def initialize(project, today: Time.zone.today)
    @project = project
    @today = today
  end

  def filename
    "#{project.client.name}-#{project.name}.csv"
  end

  def to_csv
    [
      line(HEADERS),
      week_rows.join,
      summary_rows.join,
      "\n",
      person_rows.join,
    ].join
  end

  private

  def add(totals, estimated, actual)
    totals[0] += estimated
    totals[1] += actual
  end

  def assignments
    @assignments ||= project.assignments.includes(:user, :work_weeks).order(:id).to_a
  end

  def format_date(date)
    date&.strftime(DATE)
  end

  def line(fields)
    CSV.generate_line(fields, col_sep: ';')
  end

  def monday(year, cweek)
    Date.commercial(year, 1, 1) + (cweek - 1).weeks
  end

  def person_rows
    assignments.group_by(&:user).flat_map do |user, user_assignments|
      months = Hash.new { |hash, key| hash[key] = [0, 0] }
      user_assignments.each { |assignment| sum_hours(assignment) { |(year, cweek), estimated, actual| add(months[monday(year, cweek).beginning_of_month], estimated, actual) } }

      months.sort.map { |month, (estimated, actual)| line([user&.name || 'TBD user', month.strftime('%B %Y'), nil, nil, estimated, actual]) }
    end
  end

  def scheduled_weeks(assignment)
    return [] unless assignment.starts_on && assignment.ends_on && assignment.estimated_weekly_hours.to_i.positive?

    first_monday = assignment.starts_on + ((8 - assignment.starts_on.cwday) % 7)
    (first_monday..assignment.ends_on).step(7).map { [it.cwyear, it.cweek] }
  end

  def sum_hours(assignment)
    planned = assignment.work_weeks.select { it.estimated_hours.positive? }.to_set { [it.year, it.cweek] }
    (scheduled_weeks(assignment) - planned.to_a).each { yield it, assignment.estimated_weekly_hours, 0 }
    assignment.work_weeks.each { yield [it.year, it.cweek], it.estimated_hours, it.actual_hours }
  end

  def summary
    @summary ||= Timeline::ProjectSummary.for([project], today: @today).fetch(project.id)
  end

  def summary_rows
    [
      ['Target', project.hours.presence],
      ['Plan (Future Plan + Actual)', summary.plan],
      ['Actual', summary.actual],
      ['Delta', summary.plan - project.hours.to_i],
    ].map { |label, value| line([label, nil, nil, nil, nil, nil, value]) }
  end

  def week_range(year, cweek)
    starts = monday(year, cweek)
    "#{format_date(starts)} - #{format_date(starts + 6)}"
  end

  def week_rows
    weeks = Hash.new { |hash, key| hash[key] = [0, 0] }
    assignments.each { |assignment| sum_hours(assignment) { |week, estimated, actual| add(weeks[week], estimated, actual) } }

    weeks.sort.each_with_index.map do |((year, cweek), (estimated, actual)), index|
      first = index.zero?
      line([(project.name if first), (format_date(project.starts_on) if first), (format_date(project.ends_on) if first), week_range(year, cweek), estimated, actual, nil])
    end
  end
end
