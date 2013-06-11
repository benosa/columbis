module Boss
  class TourDurationReport < Report
    arel_tables :claims
    available_results :count
    attribute :intervals # example: { values: [0, 10, 20], names: ['0-10', '10-20'] }

    attr_accessible :intervals

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      unless intervals
        values = [5, 8, 10, 14]
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
          values: values.unshift(0),
          names: names
        }
      end
    end

    def interval_field(column, use_name = true)
      expr = ''
      intervals[:values].each_with_index do |value, i|
        next_value = intervals[:values][i+1]
        res_value = use_name ? intervals[:names][i] : i
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
        claims.project(
            "#{interval_field('(claims.departure_date-claims.arrival_date)')} AS name",
            claims[:id].count.as('count'),
            "#{interval_field('(claims.departure_date-claims.arrival_date)', false)} AS interval"
          )
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:departure_date].not_eq(nil).and(claims[:arrival_date].not_eq(nil)))
          .where(claims[:departure_date].gt(claims[:arrival_date]))
          .group('name', 'interval')
          .order('interval')
      end
  end
end

#def base_query
      #  claims.project(
      #      "#{interval_field('(claims.departure_date-claims.arrival_date)')} AS name",
      #      claims[:id].count.as('count'),
      #      "#{interval_field('(claims.departure_date-claims.arrival_date)', false)} AS interval"
      #    )
      #    .where(claims[:company_id].eq(company.id))
      #    .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
      #    .group('name', 'interval')
      #    .order('interval')
      #end

#SELECT
#  (CASE
#    WHEN 0 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 5 THEN 'до 5'
#    WHEN 5 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 8 THEN 'от 5 до 8'
#    WHEN 8 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 10 THEN 'от 8 до 10'
#    WHEN 10 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 14 THEN 'от 10 до 14'
#    WHEN 14 < (claims.departure_date-claims.arrival_date) THEN 'больше 14'
#  END) AS name,
#COUNT("claims"."id") AS count,
#  (CASE
#    WHEN 0 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 5 THEN '5'
#    WHEN 5 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 8 THEN '5-8'
#    WHEN 8 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 10 THEN '8-10'
#    WHEN 10 < (claims.departure_date-claims.arrival_date) AND (claims.departure_date-claims.arrival_date) <= 14 THEN '10-14'
#    WHEN 14 < (claims.departure_date-claims.arrival_date) THEN '14'
#   END) AS interval
#FROM "claims"
#WHERE "claims"."company_id" = 8 AND "claims"."reservation_date" >= '2013-02-01' AND "claims"."reservation_date" <= '2013-12-31'
#GROUP BY name, interval
#ORDER BY interval









