class StaffplansListSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :gravatar_url, :staffplan_url, :full_name, :email, :estimated_total, :actual_total, :diff, :upcoming_estimated_hours, :work_weeks

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def staffplan_url
    staffplan_path(object)
  end

  def gravatar_url
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def upcoming_estimated_hours
    object.staffplans_work_weeks_view.where(beginning_of_week: Date.today.at_beginning_of_week.to_time.to_i..Float::INFINITY).inject(0) do |sum, value|
      sum += (value.estimated_total || 0)
    end
  end

  def scoped_staffplans_work_weeks_view
    @scoped_list_work_weeks ||= object.staffplans_work_weeks_view.where(beginning_of_week: @options[:from].to_i..@options[:to].to_i)
  end

  def work_weeks
    range = (@options[:from].to_i..@options[:to].to_i)

    range.step(604800000).inject([]) do |array, bow|
      dow = Time.at(bow / 1000).to_date
      existing_work_weeks = scoped_staffplans_work_weeks_view.select { |eww| eww.cweek == dow.cweek && eww.year == dow.year }.compact

      if existing_work_weeks.any?
        array << existing_work_weeks.inject(build_work_week(dow, bow)) do |hash, eww|
          hash[:estimated_total] += eww.estimated_total
          hash[:actual_total] += eww.actual_total
          hash[:estimated_proposed] += eww.estimated_total if eww.assignment.proposed?
          hash[:estimated_planned] += eww.estimated_total if !eww.assignment.proposed?

          hash
        end
      else
        array << build_work_week(dow, bow)
      end

      array
    end.compact

  end

  def build_work_week(dow, bow)
    { cweek: dow.cweek,
      year: dow.year,
      beginning_of_week: bow,
      estimated_total: 0,
      actual_total: 0,
      user_id: object.id,
      estimated_proposed: 0,
      estimated_planned: 0 }
  end

  def estimated_total
    object.staffplans_totals_view.estimated_total rescue 0
  end

  def actual_total
    object.staffplans_totals_view.actual_total rescue 0
  end

  def diff
    object.staffplans_totals_view.diff rescue 0
  end

  def url
    "/staffplans/#{object.id}"
  end
end
