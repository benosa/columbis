module Boss
  module MarginGroup
    extend ActiveSupport::Concern

    def months_column_settings_with_extra(data)
      categories = months_categories(data)
      series = months_serialize_data_with_extra(data, categories)
      categories.map! {|c| I18n.t('.date.months')[c-1] }
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

      def months_serialize_data_with_extra(data, categories)
        seria = []
        group_id = !extra.blank? ? extra : data.first['id']
        this_year = categories.map do |c|
          elem = data
            .select{|e| !e["percent"] }
            .find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == group_id }
          elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
        end
        last_year = categories.map do |c|
          elem = data
            .select{|e| !e["percent"] }
            .find_all { |d| d['month'].to_i == c && d['year'].to_i == (@end_date.year - 1) && d['id'] == group_id }
          elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
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
          seria.push({
            name: I18n.t('income_report.percent'),
            data: categories.map do |c|
              elem = data
                .select{|e| e["percent"] }
                .find_all { |d| d['month'].to_i == c && d['year'].to_i == @end_date.year && d['id'] == group_id }
              elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
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