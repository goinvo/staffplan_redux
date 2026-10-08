# frozen_string_literal: true

module People
  class SortColumnsComponent < ViewComponent::Base
    COLUMNS = [
      ['client', 'Client', 'sm:max-w-[67px] md:max-w-[85px] lg:max-w-[110px]'],
      ['project', 'Projects', 'sm:max-w-[230px] md:max-w-[285px] lg:max-w-[280px] md:pl-[8px] ml-8'],
    ].freeze

    attr_reader :sort

    def initialize(sort:)
      @sort = sort
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
