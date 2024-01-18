module Settings
  class TabsComponent < ViewComponent::Base

    LINK_CSS_CLASS = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium"
    SELECTED_LINK_CSS_CLASS = "border-indigo-500 text-indigo-600 whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium"

    def initialize

    end

    def settings_link(text, path)
      css_class = current_page?(path) ? SELECTED_LINK_CSS_CLASS : LINK_CSS_CLASS

      options = {}
      options[:"aria-current"] = "page" if current_page?(path)

      link_to text, path, class: css_class, **options
    end

    def settings_option(text, path)
      content_tag(:option, text, value: path, selected: current_page?(path))
    end
  end
end