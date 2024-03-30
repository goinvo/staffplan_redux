module ApplicationHelper
  def header_link_to(text, path)
    css_classes = if current_page?(path) || request.url.match(path) != nil
      "bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium"
    else
      "text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium"
    end

    link_to text, path, class: css_classes
  end

  def mobile_header_link_to(text, path)
    css_classes = if current_page?(path)
      "bg-gray-900 text-white block px-3 py-2 rounded-md text-base font-medium"
    else
      "text-gray-300 hover:bg-gray-700 hover:text-white block px-3 py-2 rounded-md text-base font-medium"
    end

    link_to text, path, class: css_classes
  end

  def avatar_image_url(target:, size: 80)
    if target.avatar.attached?
      target.avatar.variant(:thumb)
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
  def avatar_image_tag(target:, size: 80, css_classes: "h-8 w-8 rounded-full")
    image_tag(avatar_image_url(target:, size:), alt: target.name, class: css_classes)
  end
end
