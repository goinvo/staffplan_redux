class StaffplansIndexUserSerializer < ActiveModel::Serializer
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
    (@options[:from].to_i..@options[:to].to_i).step(604800000).inject([]) do |array, bow|
      dow = Time.at(bow / 1000).to_date

      estimated_proposed = 0
      estimated_planned = 0
      actual_total = 0

      object.staffplans_list_views.select { |slv| slv.cweek == dow.cweek && slv.year == dow.year }.each do |staffplan_list_view|
        estimated_proposed += staffplan_list_view.proposed? ? staffplan_list_view.estimated_total.to_i : 0
        estimated_planned += staffplan_list_view.proposed? ? 0 : staffplan_list_view.estimated_total.to_i
        actual_total += staffplan_list_view.actual_total || 0
      end

      array << {
        cweek: dow.cweek,
        year: dow.year,
        beginning_of_week: bow,
        estimated_hours: estimated_proposed + estimated_planned,
        actual_hours: actual_total,
        estimated_proposed: estimated_proposed,
        estimated_planned: estimated_planned
      }

      array
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
