class StaffplanListSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :gravatar_url, :staffplan_url, :full_name, :email, :work_weeks, :estimated_total, :actual_total, :diff, :upcoming_estimated_hours

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def staffplan_url
    staffplans_path(object)
  end

  def gravatar_url
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def upcoming_estimated_hours
    object.staffplans_list_views.inject(0) do |sum, value|
      today = Date.today
      # values in the future from today.
      if value.year.to_i > today.year.to_i || (today.year.to_i == value.year.to_i && value.cweek.to_i >= today.cweek.to_i)
        sum += (value.estimated_total || 0)
      end

      sum
    end
  end

  def work_weeks
    object.staffplans_list_views.group_by {|slv| {cweek: slv.cweek, year: slv.year}}.map do |key, values|
      estimated_proposed = values.select(&:proposed).inject(0) {|sum, value| sum += (value.estimated_total || 0)}
      estimated_planned = values.reject(&:proposed).inject(0) {|sum, value| sum += (value.estimated_total || 0)}

      key.merge(
        beginning_of_week: values.first.beginning_of_week,
        estimated_hours: estimated_proposed + estimated_planned,
        actual_hours: values.inject(0) {|sum, value| sum += (value.actual_total || 0)},
        estimated_proposed: estimated_proposed,
        estimated_planned: estimated_planned
      )
    # TODO: use a SortedSet here?
    end.sort { |x,y| x[:beginning_of_week] <=> y[:beginning_of_week] }
  end

  def estimated_total
    object.staffplans_list_views.inject(0) { |sum, slv| sum += (slv.estimated_total || 0) }
  end

  def actual_total
    object.staffplans_list_views.inject(0) { |sum, slv| sum += (slv.actual_total || 0) }
  end

  def diff
    object.staffplans_list_views.inject(0) { |sum, slv| sum += (slv.diff || 0) }
  end

  def url
    "/staffplans/#{object.id}"
  end
end
