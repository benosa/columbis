module Boss
  module Margin
    extend ActiveSupport::Concern

    MARGIN_TYPES = ['profit', 'profit_acc']

    included do
      available_results :percent
      available_results :data
      attribute :margin_type, :default => 'profit_acc'
      attr_accessible :margin_type
    end

    module InstanceMethods
      def prepare(options = {})
        @query_type = margin_type
        super
        case margin_type
          when 'profit'
            @query_type = 'profit_in_percent'
          else
            @query_type = 'profit_in_percent_acc'
        end
        case period
          when 'day'
            @results[:percent]  = build_result(query: days_query)
          when 'week'
            @results[:percent]  = build_result(query: weeks_query)
          when 'month'
            @results[:percent]  = build_result(query: months_query)
          else
            @results[:percent]  = build_result(query: years_query)
        end
        @results[:data] = @results[:amount].data + @results[:percent].data.map!{|e| e.merge("percent" => true)}
        self
      end

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

        def query
          query = claims
            .where(claims[:company_id].eq(company.id))
            .where(claims[:reservation_date].gteq(@start_date))
            .where(claims[:reservation_date].lteq(@end_date))
            .where(claims[:canceled].eq(false))
            .where(claims[:excluded_from_profit].eq(false))
          case @query_type
          when 'profit'
            query.project(claims[:profit].sum.as('amount'))
          when 'profit_in_percent'
            query.project(claims[:profit_in_percent].average.as('amount'))
          when 'profit_in_percent_acc'
            query.project(claims[:profit_in_percent_acc].average.as('amount'))
          else
            query.project(claims[:profit_acc].sum.as('amount'))
          end
        end

        def years_query
          base_query.project("extract(year from reservation_date) AS year")
            .group(:year)
            .order(:year)
        end

        def months_query
          years_query.project("extract(month from reservation_date) AS month")
            .group(:month)
            .order(:month)
        end

        def days_query
          months_query.project("extract(day from reservation_date) AS day")
            .group(:day)
            .order(:day)
        end

        def weeks_query
          years_query.project("extract(week from reservation_date) AS week")
            .group(:week)
            .order(:week)
        end

        def days_serialize_data_with_percent(data, categories)
          seria = days_serialize_data(data.select{|e| !e[:percent] }, categories)
          seria.push({
            name: I18n.t('income_report.sum'),
            data: categories.map do |c|
              elem = data.select{|e| e["percent"] }.find_all { |d| "#{d['day']}.#{d['month']}.#{d['year']}".to_datetime == c }
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

        def months_serialize_data_with_percent(data, categories)
          seria = months_serialize_data(data.select{|e| !e[:percent] }, categories)
          seria.push({
            name: I18n.t('income_report.sum'),
            data: categories.map do |c|
              elem = data.select{|e| e["percent"] }.find_all { |d| d['month'].to_i == c and d['year'].to_i == @end_date.year }
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

        def weeks_serialize_data_with_percent(data, categories)
          seria = weeks_serialize_data(data.select{|e| !e[:percent] }, categories)
          seria.push({
            name: I18n.t('income_report.sum'),
            data: categories.map do |c|
              elem = data.select{|e| e["percent"] }.find_all { |d| ("1.1.#{d['year']}".to_datetime + (d['week'].to_i*7).days - 4.days) == c }
              elem.length==0 ? [c.to_i * 1000, 0] : [c.to_i * 1000, elem.first['amount'].to_f.round(2)]
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
            name: I18n.t('income_report.sum'),
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
              text: "Text1"
            }
          }, {
            title: {
              text: "Text2"
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
              text: "Text1"
            }
          }, {
            title: {
              text: "Text2"
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
              text: "Text1"
            }
          }, {
            title: {
              text: "Text2"
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
              text: "Text1"
            }
          }, {
            title: {
              text: "Text2"
            },
            opposite: true,
            min: 0,
            max: 100
          }]
          settings
        end
    end
  end
end
