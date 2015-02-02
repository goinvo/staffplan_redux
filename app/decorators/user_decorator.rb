class UserDecorator < Draper::Decorator
  delegate_all

  attr_accessor :work_weeks_cache

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def staffplan_url
    staffplan_path(object)
  end

  def gravatar_url
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
  end

  def url
    "/staffplans/#{object.id}"
  end

end
