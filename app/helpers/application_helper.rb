# frozen_string_literal: true

module ApplicationHelper
  FEEDBACK_MAILTO = 'mailto:staffplan@goinvo.com?subject=StaffPlan%20Feedback'
  OPEN_SOURCE_URL = 'https://github.com/goinvo/staffplan-next-app'

  def main_nav_links
    my_staffplan_path = person_path(current_user)

    [
      ['My StaffPlan', my_staffplan_path, request.path == my_staffplan_path],
      ['People', people_path, request.path.start_with?(people_path) && request.path != my_staffplan_path],
      ['Projects', projects_path, request.path.start_with?(projects_path)],
    ]
  end

  def shortcuts_data
    {
      controller: 'shortcuts',
      action: 'keydown@window->shortcuts#navigate',
      shortcuts_my_staffplan_url_value: person_path(current_user),
      shortcuts_people_url_value: people_path,
      shortcuts_projects_url_value: projects_path,
    }
  end
end
