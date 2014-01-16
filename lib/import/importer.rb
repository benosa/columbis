module Import
  class Importer
    attr_reader :file, :tables, :company

    def initialize(tables, file, company, import_new)
      @tables = tables
      @file = (Rails.root + "uploads/#{company.to_s}/import.xls").to_s
      @company = Company.find company
      @import_new = ImportInfo.find import_new
      FileUtils.mkdir_p(File.dirname(@file))
      FileUtils.cp(file, @file)
    end

    def start
      @tables.each do |table|
        line = 2
        get_rows(columns_count(table), sheet_number(table)).each do |row|
          import(table, row, line)
          line += 1
        end
      end
    end

    def columns_count(table)
      begin
        "import/tables/#{table.to_s}_table".camelize.constantize.try(:columns_count).to_i
      rescue
        Rails.logger.info "Import operation warning. Importing [#{table.to_s}]. Columns count was null"
        0
      end
    end

    def sheet_number(table)
      begin
        "import/tables/#{table.to_s}_table".camelize.constantize.try(:sheet_number).to_i
      rescue
        Rails.logger.info "Import operation warning. Importing [#{table.to_s}]. Sheet number was null"
        0
      end
    end

    def get_rows(column_count, sheet_number)
      []
    end

    def import(table, row, line)
      #begin
       # table = "import/tables/#{table.to_s}_table".camelize.constantize.import(row, @company, @import_new)
        table = "import/tables/#{table.to_s}_table".camelize.constantize.new
        table.import(row, @company, @import_new, line)
      #rescue
      #  Rails.logger.info "Import operation error. Importing #{row.to_s} to [#{table.to_s}] fail. Check params"
      #  false
      #end
    end
  end
end