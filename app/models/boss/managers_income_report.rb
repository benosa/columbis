# -*- encoding : utf-8 -*-
module Boss
  class ManagersIncomeReport < IncomeReport
    arel_tables :users
    available_results :total
    attribute :total_filter
    attr_accessible :total_filter

    attr_accessor :total_names

    def prepare(options = {})
      self.sort_dir = "desc" if !(options[:sort_dir] || options[:dir] || self.sort_dir)
      self.sort_col = "total" if !(options[:sort_col] || options[:col] || self.sort_col)
      @results[:total] = build_result(query: total_query, typecast: {total: :to_i}).sort!
      @total_names = get_total_names @results[:total].data
      super
    end

    protected

      def base_query
        query.project(users[:id].as('id'), users[:color].as('color'),
        "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name")
          .join(users).on(claims[:user_id].eq(users[:id]))
          .group(users[:id])
      end

      def total_query
        base_table = base_query.as('base_table')

        ret = payments.project(base_table[:id].as('id'), base_table[:name], base_table[:color], base_table[:amount].sum.as('total'))
          .from(base_table)
          .group(:id, :name, :color)
          .order(:total)

        if total_filter
          ret.where(base_table[:id].in(total_filter))
        end

        ret
      end

      def days_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            elem = data.find_all { |d| "#{d['day']}.#{d['month']}.#{d['year']}".to_datetime == c and d['id'] == manager[:id] }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
          {
            name: manager[:name],
            data: series_data,
            color: manager[:color]
          }
        end
      end

      def months_serialize_data(data, categories)
        this_year = @total_names.map do |manager|
          series_data = categories.map do |c|
            elem = data.find_all { |d| d['month'].to_i == c and d['year'].to_i == @end_date.year and d['id'] == manager[:id] }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
          {
            name: "#{manager[:name]} #{@end_date.year}",
            data: series_data,
            color: manager[:color],
            stack: @end_date.year
          }
        end
        last_year = @total_names.map do |manager|
          series_data = categories.map do |c|
            elem = data.find_all { |d| d['month'].to_i == c and d['year'].to_i == (@end_date.year - 1) and d['id'] == manager[:id] }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
          {
            name: "#{manager[:name]} #{@end_date.year - 1}",
            data: series_data,
            color: manager[:color],
            stack: @end_date.year - 1
          }
        end
        seria = []
        if last_year.any? {|elem| elem[:data].any?{|e| e != 0} == true }
          seria+=last_year
        end
        if this_year.any? {|elem| elem[:data].any?{|e| e != 0} == true }
          seria+=this_year
        end
        seria
      end

      def weeks_serialize_data(data, categories)
        @total_names.map do |manager|
          series_data = categories.map do |c|
            elem = data.find_all { |d| ("1.1.#{d['year']}".to_datetime + (d['week'].to_i*7).days - 4.days) == c and d['id'] == manager[:id] }
            elem.length==0 ? [c.to_i * 1000, 0] : [c.to_i * 1000, elem.first['amount'].to_f.round(2)]
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
        settings[:tooltip].merge!(:shared => false)
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
        settings[:tooltip].merge!(:shared => false)
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
        settings[:tooltip].merge!(:shared => false)
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