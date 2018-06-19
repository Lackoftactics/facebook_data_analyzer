module FacebookDataAnalyzer
  module ExcelExporterMixin
    def export_sheet(package:, view_model:)
      package.workbook.add_worksheet(name: view_model[:view_model_name]) do |sheet|
        view_model[:meta].each do |row|
          sheet.add_row row
        end
        sheet.add_row [''] if view_model[:meta].any?

        view_model[:tables].each do |id, table|
          table[:meta].each do |row|
            sheet.add_row row
          end

          table[:headers].each do |row|
            sheet.add_row row
          end

          table[:rows].each do |row|
            sheet.add_row row
          end

          sheet.add_row ['']
        end
      end
    end
  end
end