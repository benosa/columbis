# -*- encoding : utf-8 -*-
module Boss
  class IncomeReport < Report
    arel_tables :payments, :claims
    available_results :amount
    attribute :period, :default => 'month'
    attr_accessible :period

    def initialize(options = {})
      super
      @end_date = Time.zone.now
      case period
      when 'day'
        @start_date = @end_date - 30.days
      when 'week'
        @start_date = @end_date - (12*7).days
      when 'year'
        @start_date = @end_date - 20.year
      else
        @start_date = @end_date - @end_date.mon - 1.year
      end
    end

    def prepare(options = {})
      case period
        when 'day'
          @results[:amount]  = build_result(query: days_query)
        when 'week'
          @results[:amount]  = build_result(query: weeks_query)
        when 'year'
          @results[:amount]  = build_result(query: years_query)
        else
          @results[:amount]  = build_result(query: months_query)
      end
      self
    end

    def days_column_settings(data)
      categories = days_categories(data)
      series = days_serialize_data(data, categories)
      categories.map! {|c| c.strftime('%d.%m.%Y') }
      days_settings(categories, series).to_json
    end

    def months_column_settings(data)
      categories = months_categories(data)
      series = months_serialize_data(data, categories)
      categories.map! {|c| I18n.t('.date.months')[c-1] }
      months_settings(categories, series).to_json
    end

    def weeks_column_settings(data)
      categories = weeks_categories(data)
      series = weeks_serialize_data(data, categories)
      weeks_settings(categories, series).to_json
    end

    def years_column_settings(data)
      categories = years_categories(data)
      series = years_serialize_data(data, categories)
      years_settings(categories, series).to_json
    end

    protected

      def query
        payments.project(payments[:amount].sum.as('amount'))
          .join(claims).on(payments[:claim_id].eq(claims[:id]))
          .where(claims[:excluded_from_profit].eq(false))
          .where(claims[:canceled].eq(false))
          .where(payments[:company_id].eq(company.id))
          .where(payments[:recipient_type].eq('Company'))
          .where(payments[:approved].eq(true))
          .where(payments[:canceled].eq(false))
          .where(payments[:date_in].gteq(@start_date))
          .where(payments[:date_in].lteq(@end_date))
      end

      def base_query
        query
      end

      def years_query
        base_query.project("extract(year from date_in) AS year")
          .group(:year)
          .order(:year)
      end

      def months_query
        years_query.project("extract(month from date_in) AS month")
          .group(:month)
          .order(:month)
      end

      def days_query
        months_query.project("extract(day from date_in) AS day")
          .group(:day)
          .order(:day)
      end

      def weeks_query
        years_query.project("extract(week from date_in) AS week")
          .group(:week)
          .order(:week)
      end

      def days_categories(data)
        start_day = "#{data.first['day']}.#{data.first['month']}.#{data.first['year']}".to_datetime
        end_date = @end_date.to_datetime
        categories = []
        x = start_day
        while x <= end_date
          categories << x
          x += 1.day
        end
        categories
      end

      def months_categories(data)
        (1..@end_date.mon).to_a
      end

      def weeks_categories(data)
        start_day = "1.1.#{data.first['year']}".to_datetime + (data.first['week'].to_i*7).days - 4.days
        end_date = @end_date.to_datetime
        categories = []
        x = start_day
        while x <= end_date
          categories << x
          x += 7.day
        end
        categories
      end

      def years_categories(data)
        (data.first['year'].to_i..@end_date.year).to_a
      end

      def days_serialize_data(data, categories)
        [{
          name: I18n.t('income_report.sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| "#{d['day']}.#{d['month']}.#{d['year']}".to_datetime == c }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
        }]
      end

      def months_serialize_data(data, categories)
        name1 = @end_date.year-1
        data1 = categories.map do |c|
          elem = data.find_all { |d| d['month'].to_i == c and d['year'].to_i == (@end_date.year - 1) }
          elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
        end
        name2 = @end_date.year
        data2 = categories.map do |c|
          elem = data.find_all { |d| d['month'].to_i == c and d['year'].to_i == @end_date.year }
          elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
        end
        seria = []
        if data1.any? {|elem| elem != 0}
          seria.push( {
            name: name1,
            data: data1
          })
        end
        if data2.any? {|elem| elem != 0}
          seria.push( {
            name: name2,
            data: data2
          })
        end
        seria
      end

      def weeks_serialize_data(data, categories)
        [{
          name: I18n.t('income_report.sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| ("1.1.#{d['year']}".to_datetime + (d['week'].to_i*7).days - 4.days) == c }
            elem.length==0 ? [c.to_i * 1000, 0] : [c.to_i * 1000, elem.first['amount'].to_f.round(2)]
          end
        }]
      end

      def years_serialize_data(data, categories)
        [{
          name: I18n.t('income_report.sum'),
          data: categories.map do |c|
            elem = data.find_all { |d| d['year'].to_i == c }
            elem.length==0 ? 0 : elem.first['amount'].to_f.round(2)
          end
        }]
      end

      def days_settings(categories, series)
        {
          chart: {
                zoomType: 'x'
          },
          title: {
            text: I18n.t('income_report.sum')
          },
          xAxis: {
            categories: categories,
            labels: {
              rotation: -90,
              align: 'right'
            }
          },
          yAxis: {
            min: 0,
            tickPixelInterval: 25,
            title: {
              text: I18n.t('income_report.yaxis_amount')
            }
          },
          tooltip: {
            formatter: nil
          },
          series: series
        }
      end

      def months_settings(categories, series)
        {
          chart: {
                zoomType: 'x'
          },
          title: {
            text: I18n.t('income_report.sum')
          },
          xAxis: {
            categories: categories,
            labels: {
              align: 'right'
            }
          },
          yAxis: {
            min: 0,
            tickPixelInterval: 25,
            title: {
              text: I18n.t('income_report.yaxis_amount')
            }
          },
          tooltip: {
            formatter: nil
          },
          legend: {
            enabled: true,
            symbolWidth: 10
          },
          series: series
        }
      end

      def weeks_settings(categories, series)
        {
          chart: {
                zoomType: 'x'
          },
          title: {
            text: I18n.t('income_report.sum')
          },
          xAxis: {
            type: 'datetime'
          },
          yAxis: {
            min: 0,
            tickPixelInterval: 25,
            title: {
              text: I18n.t('income_report.yaxis_amount')
            }
          },
          tooltip: {
            formatter: nil,
            shared: true,
            useHTML: true,
            headerFormat: ''
          },
          series: series
        }
      end

      def years_settings(categories, series)
        {
          title: {
            text: I18n.t('income_report.sum')
          },
          xAxis: {
            categories: categories,
            labels: {
              align: 'right'
            }
          },
          yAxis: {
            min: 0,
            tickPixelInterval: 25,
            title: {
              text: I18n.t('income_report.yaxis_amount')
            }
          },
          tooltip: {
            formatter: nil
          },
          series: series
        }
      end
  end
end