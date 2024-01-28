module Settings
  class TabsComponent < ViewComponent::Base

    LINK_CSS_CLASS = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 whitespace-nowrap border-b-2 px-1 pb-4 text-sm font-medium"
    SELECTED_LINK_CSS_CLASS = "border-indigo-500 text-indigo-600 whitespace-nowrap border-b-2 px-1 pb-4 text-sm font-medium"

    renders_one :action_buttons
    renders_one :header

    def initialize

    end

    def settings_link(text, path)
      css_class = current_or_starts_with?(path) ? SELECTED_LINK_CSS_CLASS : LINK_CSS_CLASS

      options = {}
      options[:"aria-current"] = "page" if current_or_starts_with?(path)

      link_to text, path, class: css_class, **options
    end

    def settings_option(text, path)
      content_tag(:option, text, value: path, selected: current_or_starts_with?(path))
    end

    private

    def current_or_starts_with?(path)
      current_page?(path)
    end
  end
end