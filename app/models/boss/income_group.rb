module Boss
  module IncomeGroup
    extend ActiveSupport::Concern

    included do
      available_results :total
      attribute :total_filter
      attribute :extra
      attr_accessible :total_filter, :extra

      attr_accessor :total_names
    end

    def prepare(options = {})
      self.sort_dir = "desc" if !(options[:sort_dir] || options[:dir] || self.sort_dir)
      self.sort_col = "total" if !(options[:sort_col] || options[:col] || self.sort_col)
      total_result
      @total_names = get_total_names @results[:total].data
      super
    end

    def months_column_settings_with_extra(data)
      categories = months_categories(data)
      series = months_serialize_data_with_extra(data, categories)
      months_settings(categories, series).to_json
    end

    protected
      def total_result
        @results[:total] = build_result(query: total_query, typecast: {total: :to_i}).sort!
      end

      def days_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            check_elements(
              data.find_all{ |d| Date.new(d['year'].to_i, d['month'].to_i, d['day'].to_i) == c &&
                d['id'] == manager[:id]}, c)
          end
          {
            name: manager[:name],
            data: series_data,
            color: manager[:color]
          }
        end
      end

      def months_serialize_data_with_extra(data, categories)
        seria = []
        group_id = !extra.blank? ? extra : (data.first['id'] if data.first)
        this_year = categories.map do |c|
          check_elements(
            data.find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == group_id },
            Date.new(@end_date.year, c, 1))
        end
        last_year = categories.map do |c|
          check_elements(
            data.find_all { |d| d['month'].to_i == c && d['year'].to_i == (@end_date.year-1) && d['id'] == group_id },
            Date.new(@end_date.year, c, 1))
        end
        if last_year.any? {|elem| elem != 0 }
          seria.push({
            name: @end_date.year-1,
            data: last_year,
            stack: @end_date.year
          })
        end
        if this_year.any? {|elem| elem != 0 }
          seria.push({
            name: @end_date.year,
            data: this_year,
            stack: @end_date.year
          })
        end
        seria
      end

      def months_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            check_elements(
              data.find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == manager[:id] },
              Date.new(@end_date.year, c, 1))
          end
          {
            name: manager[:name],
            data: series_data,
            color: manager[:color]
          }
        end
      end

      def weeks_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            check_elements(
              data.find_all { |d| (Date.new(d['year'].to_i, 1, 1) + (d['week'].to_i*7).days - 4.days) == c &&
                d['id'] == manager[:id] },
              c)
          end
          {
            name: manager[:name],
            data: series_data,
            color: manager[:color]
          }
        end
      end

      def years_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            elem = data.find_all { |d| d['year'].to_i == c and d['id'] == manager[:id] }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
          {
            name: manager[:name],
            data: series_data,
            color: manager[:color]
          }
        end
      end

      def days_settings(categories, series)
        settings = super
        settings[:yAxis].merge!(:stackLabels => {:enabled => true})
        settings.merge!(
          legend: {
            enabled: true,
            symbolWidth: 10,
            margin: 35
          }
        )
        settings
      end

      def months_settings(categories, series)
        settings = super
        settings[:yAxis].merge!(:stackLabels => {:enabled => true})
        settings
      end

      def weeks_settings(categories, series)
        settings = super
        settings[:yAxis].merge!(:stackLabels => {:enabled => true})
        settings.merge!(
          legend: {
            enabled: true,
            symbolWidth: 10
          }
        )
        settings
      end

      def years_settings(categories, series)
        settings = super
        settings[:yAxis].merge!(:stackLabels => {:enabled => true})
        settings.merge!(
          legend: {
            enabled: true,
            symbolWidth: 10
          }
        )
        settings
      end

      def get_total_names(data)
        data.map { |d| { :id => d['id'], :name => d['name'], :color => d['color'] } }.uniq
      end
  end
end