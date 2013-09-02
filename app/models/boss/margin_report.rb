# -*- encoding : utf-8 -*-
module Boss
  class MarginReport < IncomeReport
    include Margin

    def days_column_settings_with_percent(data)
      categories = days_categories(data)
      series = days_serialize_data_with_percent(data, categories)
      categories.map! {|c| c.strftime('%d.%m.%Y') }
      days_settings_with_percent(categories, series).to_json
    end

    def months_column_settings_with_percent(data)
      categories = months_categories(data)
      series = months_serialize_data_with_percent(data, categories)
      categories.map! {|c| I18n.t('.date.months')[c-1] }
      months_settings_with_percent(categories, series).to_json
    end

    def weeks_column_settings_with_percent(data)
      categories = weeks_categories(data)
      series = weeks_serialize_data_with_percent(data, categories)
      weeks_settings_with_percent(categories, series).to_json
    end

    def years_column_settings_with_percent(data)
      categories = years_categories(data)
      series = years_serialize_data_with_percent(data, categories)
      years_settings_with_percent(categories, series).to_json
    end

    protected

      def days_serialize_data_with_percent(data, categories)
        seria = days_serialize_data(data.select{|e| !e[:percent] }, categories)
        seria.push({
          name: I18n.t('income_report.percent'),
          data: categories.map do |c|
            check_elements(
              data.select{|e| e["percent"] }
                .find_all { |d| Date.new(d['year'].to_i, d['month'].to_i, d['day'].to_i) == c },
              c)
          end,
          type: 'spline',
          yAxis: 1,
          tooltip: {
            valueSuffix: ' %'
          }
        })
        seria
      end

      def months_serialize_data_with_percent(data, categories)
        seria = months_serialize_data(data.select{|e| !e[:percent] }, categories)
        seria.push({
          name: I18n.t('income_report.percent'),
          data: categories.map do |c|
            check_elements(
              data.select{|e| e["percent"] }
                .find_all { |d| d['month'].to_i == c and d['year'].to_i == @end_date.year },
                Date.new(@end_date.year, c, 1))
          end,
          type: 'spline',
          yAxis: 1,
          tooltip: {
            valueSuffix: ' %'
          }
        })
        seria
      end

      def weeks_serialize_data_with_percent(data, categories)
        seria = weeks_serialize_data(data.select{|e| !e[:percent] }, categories)
        seria.push({
          name: I18n.t('income_report.percent'),
          data: categories.map do |c|
            check_elements(
              data.select{|e| e["percent"] }
                .find_all { |d| (Date.new(d['year'].to_i, 1, 1) + (d['week'].to_i*7).days - 4.days) == c },
              c)
          end,
          type: 'spline',
          yAxis: 1,
          tooltip: {
            valueSuffix: ' %'
          }
        })
        seria
      end

      def years_serialize_data_with_percent(data, categories)
        seria = years_serialize_data(data.select{|e| !e[:percent] }, categories)
        seria.push({
          name: I18n.t('income_report.percent'),
          data: categories.map do |c|
            elem = data.select{|e| e["percent"] }.find_all { |d| d['year'].to_i == c }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end,
          type: 'spline',
          yAxis: 1,
          tooltip: {
            valueSuffix: ' %'
          }
        })
        seria
      end

      def days_settings_with_percent(categories, series)
        settings = days_settings(categories, series)
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

      def months_settings_with_percent(categories, series)
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

      def weeks_settings_with_percent(categories, series)
        settings = weeks_settings(categories, series)
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

      def years_settings_with_percent(categories, series)
        settings = years_settings(categories, series)
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
  end
end