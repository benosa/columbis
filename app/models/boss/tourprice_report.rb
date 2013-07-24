# -*- encoding : utf-8 -*-
module Boss
  class TourpriceReport < Report

    arel_tables :claims, :tourist_claims
    available_results :count
    attribute :intervals # example: { values: [0, 10, 20], names: ['0-10', '10-20'] }

    attr_accessible :intervals

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      unless intervals
        values = [10, 15, 20, 30, 50]
        names = values.to_enum(:each_with_index).map do |value, i|
          if i == 0
            I18n.t("intervals.names.before", value: value)
          else
            prev_value = values[i - 1]
            I18n.t("intervals.names.range", value1: prev_value, value2: value)
          end
        end
        names << I18n.t("intervals.names.after", value: values[values.length - 1])
        self.intervals = {
          values: values.map{ |v| v*1000 }.unshift(0),
          names: names
        }
      end
    end

    def interval_field(column, use_name = true)
      expr = ''
      intervals[:values].each_with_index do |value, i|
        next_value = intervals[:values][i+1]
        res_value = use_name ? intervals[:names][i] : (i == 0 ? next_value : (i == intervals[:values].length - 1 ? value : "#{value}-#{next_value}"))
        expr +=
          if i < intervals[:values].length - 1
            "WHEN #{value} <= #{column} AND #{column} < #{next_value}"
          else
            "WHEN #{value} <= #{column}"
          end
        expr += " THEN '#{res_value}' "
      end
      expr.blank? ? column : "(CASE #{expr} END)"
    end

    def prepare(options = {})
      @results[:count] = build_result(query: base_query, typecast: {count: :to_i})
      self
    end

    def bar_settings(factor, data)
      title = I18n.t('report.claim_quantity')
      ytitle = I18n.t('report.pcs')

      settings = {
        title: {
          text: title
        },
        xAxis: {
          categories: data.map{ |o| o['name'] }
        },
        yAxis: {
          title: {
            text: ytitle
          }
        },
        series: [{
          name: title,
          data: data.map{ |o| o[factor.to_s] }
        }]
      }.to_json
    end

    def pie_settings(factor, data)
      title = I18n.t('report.claim_quantity')

      settings = {
        title: {
          text: title
        },
        series: [{
          type: 'pie',
          name: title,
          data: data.map{ |o| [o['name'], o[factor.to_s]] }
        }]
      }.to_json
    end

    private

      def base_query
        tourists_number = tourist_claims.project(tourist_claims[:claim_id], tourist_claims[:claim_id].count.as('number'))
          .group(:claim_id)
          .as('tourists_number')

        claims.project(
            "#{interval_field('claims.primary_currency_price/tourists_number.number')} AS name",
            claims[:id].count.as('count'),
            "#{interval_field('claims.primary_currency_price/tourists_number.number', false)} AS interval")
          .join(tourists_number).on(tourists_number[:claim_id].eq(claims[:id]))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:canceled].eq(false))
          .where(claims[:excluded_from_profit].eq(false))
          .group(:name, :interval)
          .order(:interval)
      end

  end
end