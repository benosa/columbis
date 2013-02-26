# -*- encoding : utf-8 -*-
module Boss
  class ReportResult
    include Enumerable

    attr_reader :report, :query, :data
    # attr_accessor :query, :data

    delegate :row_count, :sort_col, :sort_dir, :to => :@report
    delegate :[], :to => :@data

    def initialize(report, options = {})
      @report = report
      @query = options[:query]
      @data = options[:data] || fetch_data
      typecast!(options[:typecast]) if options[:typecast]
    end

    # Enumerable interface

    def each(&block)
      @data.each(&block)
    end

    def <=>(other)
      @data.send(:'<=>', other)
    end

    # Instance methods

    def fetch_data
      if @query
        query = @query
        query = query.to_sql if query.respond_to?(:to_sql)
        ActiveRecord::Base.connection.execute(query).to_a
      else
        []
      end
    end

    def merge(*args)
      self.class.merge @report, *args.unshift(@data)
    end

    def sort(options = {})
      sort_col = (options[:sort_col] || self.sort_col).to_s
      sort_dir = (options[:sort_dir] || self.sort_dir).to_sym
      @data.sort do |h1, h2|
        if sort_dir == :asc
          h1[sort_col].nil? ? -1 : (h2[sort_col].nil? ? 1 : h1[sort_col] <=> h2[sort_col])
        else
          h2[sort_col].nil? ? -1 : (h1[sort_col].nil? ? 1 : h2[sort_col] <=> h1[sort_col])
        end
      end
    end

    def sort!(options = {})
      @data = sort(options)
      self
    end

    def typecast!(columns = [])
      unless columns.empty?
        @data.each do |row|
          columns.each do |column, method_and_args|
            column = column.to_s
            row[column] = row[column].send(*method_and_args)
          end
        end
      end
      self
    end

    def typecast(columns = [])
      _data = @data.clone
      typecast!(columns)
      data, @data = @data, _data
      data
    end

    def compact(options = {})
      row_count = options[:row_count] || self.row_count
      return @data.clone if row_count.to_sym == :all
      row_count = row_count.to_i

      columns = (options[:columns].kind_of?(Array) ? options[:columns] : [options[:columns]]) || []
      if options[:name].kind_of?(Array)
        name_col, title = options[:name][0], options[:name][1]
      elsif options.key?(:name)
        name_col, title = 'name', options[:name]
      else
        name_col, title = 'name', I18n.t('reports.title.others')
      end

      data = @data[0, row_count - 1]

      last = { name_col => title }
      remaining_data = @data.from(row_count)
      args = [:to_i]
      columns.each do |col|
        if col.kind_of?(Array)
          column, args = col[0], col.from(1)
        else
          column = col
        end
        last[column] = remaining_data.inject(0){ |sum, row| sum + (row[column].kind_of?(Numeric) ? row[column] : row[column].send(*args)) }
      end

      data << last
    end

    # Class methods

    class << self

      def merge(report, *args)
        options = args.extract_options!

        key_col = (options[:key] || 'id').to_s

        data_hash = {}
        args.each do |arg|
          data = arg.data if arg.kind_of?(self)
          data = [data].compact unless data.kind_of?(Array)
          next if data.empty?

          data.each do |hash|
            key_val = hash[key_col]
            unless data_hash[key_val]
              data_hash[key_val] = hash.clone
            else
              hash.each { |col, val| data_hash[key_val][col] = val }
            end
          end
        end

        self.new report, data: data_hash.values
      end

    end

  end
end