module Settings
  class BreadcrumbsComponent < ViewComponent::Base

    renders_many :breadcrumbs, Settings::BreadcrumbComponent
  end
end