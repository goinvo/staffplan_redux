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
  def user_gravatar(user:, size: 80, css_classes: "h-8 w-8 rounded-full")
    image_tag(user.avatar_url(size:), alt: user.name, class: css_classes)
  end
end
