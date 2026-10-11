# frozen_string_literal: true

require 'test_helper'

module Projects
  class ProjectHeaderComponentTest < ViewComponent::TestCase
    setup do
      @project = create(:project, client: create(:client, name: 'Acme'), name: 'Website')
    end

    test 'subtitles the client and date range like React' do
      {
        [nil, nil] => 'Acme',
        [Date.new(2026, 10, 1), nil] => 'Acme, Starts 1.Oct.2026',
        [nil, Date.new(2026, 12, 15)] => 'Acme, Ends 15.Dec.2026',
        [Date.new(2026, 10, 1), Date.new(2026, 12, 15)] => 'Acme, 1.Oct — 15.Dec.2026',
        [Date.new(2026, 10, 1), Date.new(2027, 2, 3)] => 'Acme, 1.Oct.2026 — 3.Feb.2027',
      }.each do |(starts_on, ends_on), subtitle|
        @project.assign_attributes(starts_on:, ends_on:)

        assert_equal subtitle, ProjectHeaderComponent.new(project: @project).subtitle
      end
    end

    test 'shows the title with the edit form hidden, and offers to unarchive' do
      @project.update!(status: Project::ARCHIVED, starts_on: Date.new(2026, 10, 5), ends_on: Date.new(2026, 12, 14))

      render_inline(ProjectHeaderComponent.new(project: @project))

      assert_selector 'h1', text: 'Website'
      assert_button 'Edit project'
      assert_selector "form[action='/projects/#{@project.id}'] input[name='project[archived]'][value=false]", visible: :all
      assert_selector 'form[hidden] input[name="project[project_name]"][value=Website]', visible: :all
      assert_selector 'form[data-project-dates-target=form][data-starts-on="2026-10-05"][data-ends-on="2026-12-14"]', visible: :all
    end

    test 'opens the form with errors' do
      form = ProjectForm.for(@project)
      form.project_name = ''
      form.validate

      render_inline(ProjectHeaderComponent.new(project: @project, form:))

      assert_selector '[data-inline-edit-target=display][hidden]', visible: :all
      assert_field 'Project name', with: ''
      assert_text 'Project name is required'
    end
  end
end
