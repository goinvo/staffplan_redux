# frozen_string_literal: true

require 'test_helper'

module Projects
  class ProjectRowComponentTest < ViewComponent::TestCase
    SUMMARY_CELLS = %w[.min-w-10 .min-w-20].freeze

    setup do
      travel_to Date.new(2026, 10, 8)
      @user = create(:membership).user
      @acme = create(:client, company: @user.current_company, name: 'Acme')
      @website, @app = %w[Website App].map { create(:project, client: @acme, name: it) }
      @window = Timeline::Window.from_param(nil)
    end

    test 'links to the project and its client, charts its weeks and summarizes its hours' do
      @website.update!(hours: 40)
      assignment = create(:assignment, project: @website, user: @user)
      next_week = @window.weeks.third
      create(:work_week, assignment:, cweek: next_week.cweek, year: next_week.year, estimated_hours: 32, actual_hours: 0)

      render_row(@website, assignments: [assignment])

      assert_link 'Website', href: "/projects/#{@website.id}"
      assert_link 'Acme', href: "/projects?client=#{@acme.id}"
      assert_selector 'td[data-timeline-week]', count: Timeline::Window::WEEK_COUNT, visible: :all
      assert_selector 'td[data-timeline-week="2"] span.text-contrastBlue', text: '32', visible: :all
      assert_equal ['Target 40hrs', 'Plan 32hrs', 'Actual 0hrs', 'Delta -8hrs'], summary_rows
      assert_no_text '(Archived)'
      assert_no_button 'Show in My StaffPlan'
    end

    test 'labels every row sorted by project, but only the first of each client sorted by client' do
      render_row(@website, previous: @app)

      assert_link 'Acme'
      assert_selector 'tr.border-t'

      render_row(@website, previous: @app, sort: 'client_asc')

      assert_no_link 'Acme'
      assert_no_selector 'tr.border-t'

      render_row(@website, previous: create(:project, client: create(:client, company: @user.current_company)), sort: 'client_asc')

      assert_link 'Acme'
      assert_selector 'tr.border-t'
    end

    test 'drops the client column in the client view' do
      render_row(@website, client_view: true)

      assert_no_link 'Acme'
      assert_link 'Website'
    end

    test 'marks archived projects and offers to show the viewer’s hidden assignment' do
      @website.update!(status: Project::ARCHIVED)
      hidden = create(:assignment, project: @website, user: @user, focused: false)

      render_row(@website, assignments: [hidden])

      assert_text '(Archived)'
      assert_selector "form[action='/assignments/#{hidden.id}'] button[aria-label='Show in My StaffPlan']"
      assert_selector 'input[name="assignment[focused]"][value=true]', visible: :all
    end

    private

    def render_row(project, assignments: [], previous: nil, sort: nil, client_view: false)
      hours = Timeline::WeeklyHours.new(assignments:, window: @window)
      render_inline(ProjectRowComponent.new(
                      project:,
                      previous:,
                      last: false,
                      sort: Timeline::ProjectSort.parse(sort),
                      client_view:,
                      hours:,
                      summary: Timeline::ProjectSummary.for([project]).fetch(project.id),
                      viewer: @user,
                    ))
    end

    def summary_rows
      page.all('[data-controller=toggle] > div', visible: :all).map { |row| SUMMARY_CELLS.map { row.find(it, visible: :all).text }.join(' ') }
    end
  end
end
