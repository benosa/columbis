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

      def check_tabs(tabs_info)
        begin
          oo = Roo::Excel.new(@file)
        rescue
          return result = { success: false, :data => {file_format: 'неверный'} }
        end

        result = { success: true, :data => {} }
        tabs_info.each do |k,v|
          #puts k.to_s + ' ' + v[:sheet_number].to_s + ' ' + oo.last_column(oo.sheets[v[:sheet_number]]).to_s
          if v[:column_count] != oo.last_column(oo.sheets[v[:sheet_number]])
            result[:data][k] = oo.last_column(oo.sheets[v[:sheet_number]]).to_s + ' вместо ' + v[:column_count].to_s
            result[:success] = false
          end
        end
        result
      end
    end
  end
end