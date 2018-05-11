module FacebookDataAnalyzer
  class Table
    def initialize(name:)
      @name = name.to_sym
      @headers = []
      @meta = []
      @rows = []
    end

    def add_headers(header)
      @headers << header
    end

    def add_row(row)
      @rows << row
    end

    def add_meta(meta)
      @meta << meta
    end

    def to_json
      { table_name: @name.dup, headers: @headers.dup, meta: @meta.dup, rows: @rows.dup }
    end

    def html_idify_name
      "##{@name.to_s.downcase.gsub(' ', '_')}"
    end
  end
end
