# frozen_string_literal: true

require 'test_helper'

module Timeline
  class AssignmentSortTest < ActiveSupport::TestCase
    Client = Data.define(:name)
    Project = Data.define(:name, :client)
    Row = Data.define(:project)

    setup do
      @rows = [%w[beta Omega], %w[Zeta alpha], %w[Beta gamma]].map do |client, project|
        Row.new(project: Project.new(name: project, client: Client.new(name: client)))
      end
    end

    test 'defaults to client ascending and ignores unknown values' do
      [nil, '', 'name_asc', 'client_sideways'].each do |value|
        assert_equal 'client_asc', AssignmentSort.parse(value).to_param
      end
    end

    test 'sorts by client, then project, ignoring case' do
      assert_equal %w[gamma Omega alpha], names(AssignmentSort.parse('client_asc'))
      assert_equal %w[alpha gamma Omega], names(AssignmentSort.parse('client_desc'))
    end

    test 'sorts by project, ignoring case' do
      assert_equal %w[alpha gamma Omega], names(AssignmentSort.parse('project_asc'))
      assert_equal %w[Omega gamma alpha], names(AssignmentSort.parse('project_desc'))
    end

    test 'clicking the sorted column flips its direction, another column starts ascending' do
      sort = AssignmentSort.parse('client_asc')

      assert_equal 'client_desc', sort.next_for('client')
      assert_equal 'project_asc', sort.next_for('project')
      assert_equal 'client_asc', AssignmentSort.parse('client_desc').next_for('client')
    end

    private

    def names(sort) = sort.apply(@rows).map { it.project.name }
  end
end
