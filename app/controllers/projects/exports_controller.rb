# frozen_string_literal: true

module Projects
  class ExportsController < RailsUiController
    def show
      export = ProjectExport.new(current_company.projects.find(params[:project_id]))

      send_data export.to_csv, filename: export.filename, type: 'text/csv; charset=utf-8'
    end
  end
end
