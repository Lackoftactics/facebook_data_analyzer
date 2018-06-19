module FacebookDataAnalyzer
  module ExportViewsMixin
    include FacebookDataAnalyzer::ExcelExporterMixin

    def initialize(*args)
      super

      analyzeable_class = self.class.name.split('::').last
      @view_model_generator = FacebookDataAnalyzer.const_get("#{analyzeable_class}ViewModelGenerator").new(analyzeable: self)
    end

    def export(package:)
      self.class::EXPORTS.each do |view_export|
        view_model = @view_model_generator.send("#{view_export}_view_model".to_sym)
        export_sheet(package: package, view_model: view_model)
      end
    end
  end
end