# frozen_string_literal: true

module People
  class PeopleColumnComponent < ViewComponent::Base
    attr_reader :sort, :add_people

    def initialize(sort:, add_people: false)
      @sort = sort
      @add_people = add_people
    end

    def sort_path
      "#{request.path}?#{request.query_parameters.merge('sort' => sort.next).to_query}"
    end
  end
end
