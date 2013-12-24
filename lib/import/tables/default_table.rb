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
    end
  end
end