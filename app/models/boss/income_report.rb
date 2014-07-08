# -*- encoding : utf-8 -*-
module Boss
  class IncomeReport < Report
    arel_tables :payments, :claims
    available_results :amount
    attribute :period, :default => 'month'
    attribute :check_date, :default => false
    attribute :no_group_date, :default => false
    attr_accessible :period, :check_date

    def initialize(options = {})
      super
      if check_date
        @start_date = start_date
        @end_date = end_date
      else
        @end_date = Time.zone.now.to_date
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
    end

    def prepare(options = {})
      if no_group_date
        @results[:amount]  = build_result(query: base_query, typecast: {amount: :to_f})
      else
        case period
          when 'day'
            @results[:amount]  = build_result(query: days_query, typecast: {amount: :to_f})
          when 'week'
            @results[:amount]  = build_result(query: weeks_query, typecast: {amount: :to_f})
          when 'year'
            @results[:amount]  = build_result(query: years_query, typecast: {amount: :to_f})
          else
            @results[:amount]  = build_result(query: months_query, typecast: {amount: :to_f})
        end
      end
      self
    end

    def days_column_settings(data)
      categories = days_categories(data)
      series = days_serialize_data(data, categories)
      days_settings(categories, series).to_json
    end

    def months_column_settings(data)
      categories = months_categories(data)
      series = months_serialize_data(data, categories)
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
        claims.project(claims[:primary_currency_price].sum.as('amount'))
          .where(claims[:excluded_from_profit].eq(false))
          .where(claims[:canceled].eq(false))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(@start_date))
          .where(claims[:reservation_date].lteq(@end_date))
      end

      def base_query
        query
      end

      def years_query
        base_query.project("extract(year from claims.reservation_date) AS year")
          .group(:year)
          .order(:year)
      end

      def months_query
        years_query.project("extract(month from claims.reservation_date) AS month")
          .group(:month)
          .order(:month)
      end

      def days_query
        months_query.project("extract(day from claims.reservation_date) AS day")
          .group(:day)
          .order(:day)
      end

      def weeks_query
        years_query.project("extract(week from claims.reservation_date) AS week")
          .group(:week)
          .order(:week)
      end

      def days_categories(data)
        categories = []
        unless data.first.nil?
          x = Date.new( data.first['year'].to_i, data.first['month'].to_i, data.first['day'].to_i )
          while x <= @end_date
            categories << x
            x += 1.days
          end
        end
        categories
      end

      def months_categories(data)
        (1..@end_date.mon).to_a
      end

      def weeks_categories(data)
        categories = []
        unless data.first.nil?
          x = Date.new(data.first['year'].to_i, 1, 1) + (data.first['week'].to_i*7).days - 4.days
          while x <= @end_date
            categories << x
            x += 7.day
          end
        end
        categories
      end

      def years_categories(data)
        categories = []
        unless data.first.nil?
          categories = (data.first['year'].to_i..@end_date.year).to_a
        end
        categories
      end

      def days_serialize_data(data, categories)
        [{
          name: I18n.t('income_report.sum'),
          data: categories.map do |c|
            check_elements(
              data.find_all { |d| Date.new(d['year'].to_i, d['month'].to_i, d['day'].to_i) == c },
              c)
          end
        }]
      end

      def months_serialize_data(data, categories)
        name1 = @end_date.year-1
        data1 = categories.map do |c|
          check_elements(
            data.find_all { |d| d['month'].to_i == c and d['year'].to_i == (@end_date.year - 1) },
            Date.new(@end_date.year, c, 1))
        end
        name2 = @end_date.year
        data2 = categories.map do |c|
          check_elements(
            data.find_all { |d| d['month'].to_i == c and d['year'].to_i == @end_date.year },
            Date.new(@end_date.year, c, 1))
        end
        seria = []
        if data1.any? {|elem| elem[1] != 0}
          seria.push( {
            name: name1,
            data: data1
          })
        end
        if data2.any? {|elem| elem[1] != 0}
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
            check_elements(
              data.find_all { |d| (Date.new(d['year'].to_i, 1, 1) + (d['week'].to_i*7).days - 4.days) == c },
              c)
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
            type: 'datetime',
            dateTimeLabelFormats: {
              month: '%b'
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
            formatter: nil,
            dateTimeLabelFormats: {
              day: '%e. %b',
              week: '%e. %b',
              month: '%e. %b',
              year: '%e. %b'
            }
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
            type: 'datetime',
            dateTimeLabelFormats: {
              month: '%b'
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
            formatter: nil,
            dateTimeLabelFormats: {
              month: '%B'
            }
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
            type: 'datetime',
            dateTimeLabelFormats: {
              week: '%e. %b'
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
            is_middle_day_of_week: true
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

      def check_elements(elements, categoria)
        elem = elements.first
        date = categoria.to_datetime.to_i * 1000
        elem.nil? ? [date, 0] : [date, elem['amount'].to_f.round(2)]
      end
  end
end