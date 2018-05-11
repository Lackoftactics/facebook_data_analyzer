module FacebookDataAnalyzer
    class ViewModelGenerator
        def initialize(analyzeable:)
            class_name = self.class.name.split('::').last
            analyzeable_name = class_name.split('ViewModelGenerator').first.downcase
            instance_variable_set("@#{analyzeable_name}", analyzeable)
        end
        private
        def build_view_model(model_name:, tables:, meta: [])
            { view_model_name: model_name, meta: meta, tables: tables.map(&:to_json) }
        end
    end
end
