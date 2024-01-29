module Settings
  class BreadcrumbsComponent < ViewComponent::Base

    renders_many :breadcrumbs, Settings::BreadcrumbComponent

    def initialize()
    end
  end
end