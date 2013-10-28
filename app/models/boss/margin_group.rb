module Boss
  module MarginGroup
    extend ActiveSupport::Concern

    def months_column_settings_with_extra(data)
      categories = months_categories(data)
      series = months_serialize_data_with_extra(data, categories)
      months_settings_with_extra(categories, series).to_json
    end

    def days_column_settings_with_percent(data, percent = true)
      @percent = percent == true ? percent : false
      days_column_settings(data)
    end

    def months_column_settings_with_percent(data, percent = true)
      @percent = percent == true ? percent : false
      months_column_settings(data)
    end

    def weeks_column_settings_with_percent(data, percent = true)
      @percent = percent == true ? percent : false
      weeks_column_settings(data)
    end

    def years_column_settings_with_percent(data, percent = true)
      @percent = percent == true ? percent : false
      years_column_settings(data)
    end

    protected
      def total_result
        @results[:total] = build_result(query: total_query, typecast: {total: :to_i, percent: :to_f}).sort!
      end

      def total_query
        ret = super
        ret.project('AVG(base_table.percent) AS percent')
        ret
      end

      def months_serialize_data_with_extra(data, categories)
        seria = []
        group_id = !extra.blank? ? extra : (data.first['id'] if data.first)
        this_year = categories.map do |c|
          check_elements(
            data.select{|e| !e["percent"] }
              .find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == group_id },
            Date.new(@end_date.year, c, 1))
        end
        last_year = categories.map do |c|
          check_elements(
            data.select{|e| !e["percent"] }
              .find_all { |d| d['month'].to_i == c && d['year'].to_i == (@end_date.year - 1) && d['id'] == group_id },
            Date.new(@end_date.year, c, 1))
        end
        if last_year.any? {|elem| elem != 0 }
          seria.push({
            name: I18n.t('income_report.sum') + ' ' + (@end_date.year-1).to_s,
            data: last_year,
            stack: @end_date.year
          })
          seria.push({
            name: I18n.t('income_report.percent') + ' ' + (@end_date.year-1).to_s,
            data: categories.map do |c|
              check_elements(
                data.select{|e| e["percent"] }
                  .find_all { |d| d['month'].to_i == c && d['year'].to_i == (@end_date.year - 1) && d['id'] == group_id },
                Date.new(@end_date.year, c, 1))
            end,
            type: 'spline',
            yAxis: 1,
            tooltip: {
              valueSuffix: ' %'
            }
          })
        end
        if this_year.any? {|elem| elem != 0 }
          seria.push({
            name: I18n.t('income_report.sum') + ' ' + @end_date.year.to_s,
            data: this_year,
            stack: @end_date.year
          })
          seria.push({
            name: I18n.t('income_report.percent') + ' ' + @end_date.year.to_s,
            data: categories.map do |c|
              check_elements(
                data.select{|e| e["percent"] }
                    .find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == group_id },
                  Date.new(@end_date.year, c, 1))
            end,
            type: 'spline',
            yAxis: 1,
            tooltip: {
              valueSuffix: ' %'
            }
          })
        end
        seria
      end

      def months_settings_with_extra(categories, series)
        settings = months_settings(categories, series)
        settings[:title].merge!({:text => I18n.t('income_report.percent_with_sum')})
        settings[:yAxis] = [{
          title: {
            text: I18n.t('income_report.yaxis_amount')
          }
        }, {
          title: {
            text: "%"
          },
          opposite: true,
          min: 0,
          max: 100
        }]
        settings
      end

      def days_settings(categories, series)
        settings = super
        if @percent
          settings[:title].merge!({:text => I18n.t('income_report.percent')})
          settings[:yAxis][:title].merge!({:text => "%"})
        end
        settings
      end

      def weeks_settings(categories, series)
        settings = super
        if @percent
          settings[:title].merge!({:text => I18n.t('income_report.percent')})
          settings[:yAxis][:title].merge!({:text => "%"})
        end
        settings
      end

      def months_settings(categories, series)
        settings = super
        if @percent
          settings[:title].merge!({:text => I18n.t('income_report.percent')})
          settings[:yAxis][:title].merge!({:text => "%"})
        end
        settings
      end

      def years_settings(categories, series)
        settings = super
        if @percent
          settings[:title].merge!({:text => I18n.t('income_report.percent')})
          settings[:yAxis][:title].merge!({:text => "%"})
        end
        settings
      end
  end
end