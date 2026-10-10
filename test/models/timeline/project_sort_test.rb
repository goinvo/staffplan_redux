# frozen_string_literal: true

require 'test_helper'

module Timeline
  class ProjectSortTest < ActiveSupport::TestCase
    setup do
      acme = Client.new(id: 1, name: 'acme')
      globex = Client.new(id: 2, name: 'Globex')
      @projects = [Project.new(name: 'zeta', client: acme), Project.new(name: 'Alpha', client: globex), Project.new(name: 'Beta', client: acme)]
    end

    test 'defaults to projects ascending and ignores unknown values' do
      [nil, '', 'people_asc', 'project_sideways'].each do |value|
        assert_equal 'project_asc', ProjectSort.parse(value).to_param
      end
    end

    test 'sorts by project name, ignoring case' do
      assert_equal %w[Alpha Beta zeta], names('project_asc')
      assert_equal %w[zeta Beta Alpha], names('project_desc')
    end

    test 'groups by client, then project name' do
      assert_equal %w[Beta zeta Alpha], names('client_asc')
      assert_equal %w[Alpha Beta zeta], names('client_desc')
    end

    private

    def names(sort)
      ProjectSort.parse(sort).apply(@projects).map(&:name)
    end
  end
end
