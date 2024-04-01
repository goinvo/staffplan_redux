class AvatarHelper
  attr_accessor :target, :size

  def initialize(target:, size: 80, css_classes: "h-8 w-8 rounded-full")
    @target = target
    @size = size
    @css_classes = css_classes
  end

  def image_url
    if target.avatar.attached?
      Rails.application.routes.url_helpers.url_for(target.avatar.variant(:thumb))
    else
      case target
      when User
        gravatar_id = Digest::MD5::hexdigest(target.email.downcase)
        "http://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
      else
        "http://www.gravatar.com/avatar"
      end
    end
  end
end