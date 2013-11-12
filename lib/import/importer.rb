module Import
  class Importer
    attr_reader :file, :tables

    def initialize(tables, file)
      @tables = tables
      @file = Rails.root + "uploads/#{current_company.id.to_s}/import.xls"
      FileUtils.copy(file.path, @file)
    end

    def start
      @tables.each do |table|
        get_rows(columns_count(table), sheet_number(table)).each do |row|
          import(table, row)
        end
      end
    end

    def columns_count(table)
      begin
        "import/tables/#{table.to_s}".camelize.constantize.columns_count
      rescue
        Rails.logger.info "Import operation warning. Importing [#{table.to_s}]. Columns count was null"
        0
      end
    end

    def sheet_number(table)
      begin
        "import/tables/#{table.to_s}".camelize.constantize.sheet_number
      rescue
        Rails.logger.info "Import operation warning. Importing [#{table.to_s}]. Sheet number was null"
        0
      end
    end

    def get_rows(column_count, sheet_number)
      []
    end

    def import(table, row)
      begin
        "tables/#{table.to_s}".camelize.constantize.import(row)
      rescue
        Rails.logger.info "Import operation error. Importing #{row.to_s} to [#{table.to_s}] fail. Check params"
        false
      end
    end
  end
end