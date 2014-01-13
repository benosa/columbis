module Import
  module Tables
    module DefaultTable
      FORMAT = {}

      def self.columns_count
        0
      end

      def self.default_row
        []
      end

      def self.sheet_number
        0
      end

      def self.import(row)
        false
      end

      def self.save_import_item(params)
        import_item = ImportItem.new(params)
        import_item.import_info = @import_new
        import_item.save
      end
    end
  end
end