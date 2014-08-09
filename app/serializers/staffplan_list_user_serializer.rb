class StaffplanListUserSerializer < ActiveModel::Serializer
  attributes :full_name, :email, :work_weeks, :estimated_total, :actual_total, :diff, :url
  
  def full_name
    "#{object.first_name} #{object.last_name}"
  end
  
  def work_weeks
    object.staffplans_list_views.group_by {|slv| {cweek: slv.cweek, year: slv.year}}.map do |key, values|
      key.merge(estimated: values.inject(0) {|sum, value| sum += (value.estimated_total || 0)}, actual: values.inject(0) {|sum, value| sum += (value.actual_total || 0)})
    end
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
