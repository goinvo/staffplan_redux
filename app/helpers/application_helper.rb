module ApplicationHelper
  def header_link_to(text, path)
    css_classes = if current_page?(path)
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
  def user_gravatar(user:, css_classes: "h-8 w-8 rounded-full")
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "http://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: css_classes)
  end

  def user_staff_plan_turbo_frame_id(viewing_user)
    "staff_plan:u:#{viewing_user.id}|c:#{current_user.current_company_id}"
  end

  def work_week_turbo_frame_id(work_week)
    frame_id = "work_week|a:#{work_week.assignment.id}"
    frame_id += "|u:#{work_week.assignment.user.id}|bow:#{work_week.beginning_of_week}"
    frame_id += "|cweek:#{work_week.cweek}|year:#{work_week.year}"
    frame_id
  end
end
