# frozen_string_literal: true

module Timeline
  class SortColumnsComponent < ViewComponent::Base
    MY_STAFFPLAN = [
      ['client', 'Client', 'sm:max-w-[67px] md:max-w-[85px] lg:max-w-[110px]'],
      ['project', 'Projects', 'sm:max-w-[230px] md:max-w-[285px] lg:max-w-[280px] md:pl-[8px] ml-8'],
    ].freeze
    PROJECTS = [
      ['client', 'Clients', 'sm:max-w-[88px] md:max-w-[109px] lg:max-w-[125px]'],
      ['project', 'Projects', 'sm:max-w-[166px] md:max-w-[216px]'],
    ].freeze
    CLIENT_PROJECTS = [['project', 'Projects', '']].freeze

    attr_reader :sort, :columns, :add_project

    def initialize(sort:, columns:, add_project: false)
      @sort = sort
      @columns = columns
      @add_project = add_project
    end

    def chevron_class(column)
      if column != sort.column
        'opacity-0 -rotate-90'
      elsif sort.desc?
        'rotate-90'
      else
        '-rotate-90'
      end
    end

    def sort_path(column)
      "#{request.path}?#{request.query_parameters.merge('sort' => sort.next_for(column)).to_query}"
    end
  end
end
