module Import
  class Importer
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def format
      {}
    end

    def get_rows
      nil
    end

    def import(row)
      true
    end
  end
end