module Import
  module Formats
    class XLS < Import::Importer
      require 'roo'

      def get_rows(column_count, sheet_number)
        oo = Roo::Excel.new(@file)
        sheet = oo.sheets[sheet_number]

        table = []
        for i in 2..oo.last_row(sheet)
          row = []
          for j in 1..column_count
            row << oo.cell(i, j, sheet)
          end
          table << row
        end
        table
      end
    end
  end
end