# frozen_string_literal: true

module Projects
  class AssignmentRowComponent < ViewComponent::Base
    attr_reader :assignment, :hours, :available_users, :inactive

    def initialize(assignment:, hours:, viewer:, manager:, available_users:, inactive: false, highlight: false) # rubocop:disable Metrics/ParameterLists
      @assignment = assignment
      @hours = hours
      @viewer = viewer
      @manager = manager
      @available_users = available_users
      @inactive = inactive
      @highlight = highlight
    end

    def avatar_url
      AvatarHelper.new(target: user).image_url
    end

    def first_name
      user ? user.name.split.first : 'person'
    end

    def hidden_from_viewer?
      user == @viewer && !assignment.focused
    end

    def proposed?
      assignment.status == Assignment::PROPOSED
    end

    def removable?
      assignment.removable_by?(@viewer, manager: @manager)
    end

    def row_class
      [
        unassigned? ? 'hidden sm:flex' : 'flex',
        'border-b border-gray-300 hover:bg-hoverGrey pl-5',
        ('bg-diagonal-stripes' if proposed?),
        ('animate-fade-in-scale' if @highlight),
      ]
    end

    def toggled_status
      proposed? ? Assignment::ACTIVE : Assignment::PROPOSED
    end

    def unassigned?
      user.nil?
    end

    delegate :user, to: :assignment
  end
end
