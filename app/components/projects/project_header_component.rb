# frozen_string_literal: true

module Projects
  class ProjectHeaderComponent < ViewComponent::Base
    FIELD = 'h-6 w-full pl-1 bg-white shadow-top-input-shadow text-tiny font-normal rounded-sm focus:border-tiffany focus:ring-2 focus:ring-tiffany border-none outline-none'
    LABEL = 'text-white font-normal text-tiny min-w-12 text-left'

    attr_reader :project, :form

    def initialize(project:, form: ProjectForm.for(project))
      @project = project
      @form = form
    end

    def client_options
      project.company.clients.order(:name).map { { value: it.name } }
    end

    def editing?
      form.errors.any?
    end

    def error(attribute)
      form.errors[attribute].first
    end

    def subtitle
      [project.client.name, dates].compact_blank.join(', ')
    end

    private

    def dates
      starts_on = project.starts_on
      ends_on = project.ends_on

      if starts_on && ends_on
        start_format = starts_on.year == ends_on.year ? '%-d.%b' : '%-d.%b.%Y'
        "#{starts_on.strftime(start_format)} — #{ends_on.strftime('%-d.%b.%Y')}"
      elsif starts_on
        "Starts #{starts_on.strftime('%-d.%b.%Y')}"
      elsif ends_on
        "Ends #{ends_on.strftime('%-d.%b.%Y')}"
      end
    end
  end
end
