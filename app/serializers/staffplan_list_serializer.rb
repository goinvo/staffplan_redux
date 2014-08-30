class StaffplanListSerializer < ActiveModel::Serializer
  attributes :id, :gravatar_url, :staffplan_url, :full_name, :email, :work_weeks, :estimated_total, :actual_total, :diff

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def staffplan_url
    staffplans_path(object)
  end

  def gravatar_url
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def work_weeks
    object.staffplans_list_views.group_by {|slv| {cweek: slv.cweek, year: slv.year}}.map do |key, values|
      key.merge(
        beginning_of_week: values.first.beginning_of_week,
        estimated: values.inject(0) {|sum, value| sum += (value.estimated_total || 0)},
        actual: values.inject(0) {|sum, value| sum += (value.actual_total || 0)},
        estimated_proposed: values.select(&:proposed).inject(0) {|sum, value| sum += (value.estimated_total || 0)},
        estimated_planned: values.reject(&:proposed).inject(0) {|sum, value| sum += (value.estimated_total || 0)}
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
