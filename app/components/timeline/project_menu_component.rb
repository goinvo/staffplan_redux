# frozen_string_literal: true

module Timeline
  class ProjectMenuComponent < ViewComponent::Base
    ARCHIVE_TITLE = 'Project archived for everyone'
    ARCHIVE_SUBTITLE = "Archiving removes the project from everyone's view, including its hours."
    HIDE_TITLE = 'Project hidden from My StaffPlan'

    attr_reader :project, :assignment

    def initialize(project:, assignment:, viewer:, manager:, assignment_row:)
      @project = project
      @assignment = assignment
      @viewer = viewer
      @manager = manager
      @assignment_row = assignment_row
    end

    def assignment_row? = @assignment_row

    def deletable?
      assignment&.removable_by?(@viewer, manager: @manager)
    end

    def delete_label
      own? ? 'Delete me from this project' : "Delete #{first_name} from this project"
    end

    def delete_title
      "Deleted #{first_name} and their proposed/plan hours from this project"
    end

    def first_name
      assignment.user ? assignment.user.name.split.first : 'person'
    end

    def own?
      assignment.present? && assignment.user_id == @viewer.id
    end
  end
end
