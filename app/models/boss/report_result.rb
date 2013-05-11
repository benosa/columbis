# -*- encoding : utf-8 -*-
module Boss
  class ReportResult
    include Enumerable

    attr_reader :report, :query, :data
    # attr_accessor :query, :data

    delegate :row_count, :show_others, :sort_col, :sort_dir, :to => :@report
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
      sort_col = (options[:sort_col] || options[:col] || self.sort_col).to_s
      sort_dir = (options[:sort_dir] || options[:dir] || self.sort_dir).to_s
      @data.sort do |h1, h2|
        if sort_dir == 'asc'
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
      row_count   = options[:row_count] || self.row_count
      show_others = options[:show_others] || self.show_others

      return @data.clone if row_count == 0

      columns = (options[:columns].kind_of?(Array) ? options[:columns] : [options[:columns]]) || []
      if options[:name].kind_of?(Array)
        name_col, title = options[:name][0], options[:name][1]
      elsif options.key?(:name)
        name_col, title = 'name', options[:name]
      else
        name_col, title = 'name', I18n.t('reports.title.others')
      end

      data = @data[0, row_count - 1]

      if show_others
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

      data
    end

    def group_by(*args)
      options = args.extract_options!
      field = args[0].to_s

      data = @data.group_by do |row|
        row[field]
      end

      data
    end

    def group_by!(*args)
      @data = group_by(*args)
      self
    end

    def adjust_groups!(options = {})
      xfield = options[:points]
      yfield = options[:factor]

      points = []
      @data.each_value do |serie|
        points += serie.map{ |row| row[xfield] }
      end
      points.uniq!.sort!
      Rails.logger.debug "points: #{points}"

      @data.each_value do |serie|
        cps = serie.map{|row| row[xfield]} # current points
        l = cps.length
        points.each_with_index do |p, i|
          if cps[i] != p
            if l > 1
              if cps[i-1] && cps[i] then i1, i2 = i-1, i
              elsif cps[i] && cps[i+1] then i1, i2 = i, i+1
              else i1, i2 = i-2, i-1
              end
              x1, y1, x2, y2 = cps[i1], serie[i1][yfield], cps[i2], serie[i2][yfield]
              value = line_value(p, [x1, y1], [x2, y2])
            else
              value = serie[0][yfield]
            end
            serie.insert i, serie[0].merge({
              xfield => p,
              yfield => value
            })
            cps.insert i, p
          end
        end
      end
      self
    end

    def line_value(x, p1, p2)
      x1, y1, x2, y2 = p1[0], p1[1], p2[0], p2[1]
      dx = x2-x1
      val = (x-x1) * (y2-y1) / dx + y1 if dx != 0
      val = 0 if dx == 0 || val < 0
      val
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