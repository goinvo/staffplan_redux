# frozen_string_literal: true

require 'test_helper'

class ProjectFormTest < ActiveSupport::TestCase
  setup do
    @company = create(:company)
    @acme = create(:client, company: @company, name: 'Acme')
    @project = create(:project, client: @acme, name: 'Website', status: Project::CONFIRMED, hours: 100)
  end

  test 'starts from the project and updates it, creating a new client' do
    form = ProjectForm.for(@project)

    assert_equal ['Website', 'Acme', '100', false], [form.project_name, form.client_name, form.hours, form.archived]

    form.assign_attributes(project_name: ' Web App ', client_name: 'Globex', hours: '1,200', starts_on: '2026-11-02', ends_on: '2027-01-04')

    assert form.save
    assert_equal ['Web App', 'Globex', 1200, Date.new(2026, 11, 2), Date.new(2027, 1, 4)],
                 [@project.reload.name, @project.client.name, @project.hours, @project.starts_on, @project.ends_on]
  end

  test 'keeps its own name but not another project’s' do
    create(:project, client: @acme, name: 'Mobile')
    form = ProjectForm.for(@project)

    assert_predicate form, :valid?

    form.project_name = 'mobile'

    assert_not form.save
    assert_equal ['Project name already in use'], form.errors[:project_name]
  end

  test 'archiving sets the status and unarchiving makes it unconfirmed' do
    update(archived: true)

    assert_equal Project::ARCHIVED, @project.reload.status

    update(archived: false)

    assert_equal Project::UNCONFIRMED, @project.reload.status
  end

  test 'leaves the status alone when the archive box stays unchecked' do
    update(hours: '80')

    assert_equal Project::CONFIRMED, @project.reload.status
  end

  test 'rejects dates out of order' do
    form = ProjectForm.for(@project)
    form.assign_attributes(starts_on: '2026-11-02', ends_on: '2026-10-05')

    assert_not form.save
    assert_equal ["End date can't be before the start date"], form.errors[:ends_on]
  end

  private

  def update(**attributes)
    form = ProjectForm.for(@project.reload)
    form.assign_attributes(attributes)

    assert form.save
  end
end
