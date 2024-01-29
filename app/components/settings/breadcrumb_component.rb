module Settings
  class BreadcrumbComponent < ViewComponent::Base

    renders_one :svg

    def initialize(title:, link: nil, first: false, last: false)
      @title = title
      @link = link
      @first = first
      @last = last
    end

    def render_slash?
      !@first
    end
  end
end