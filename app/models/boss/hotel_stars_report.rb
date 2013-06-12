module Boss
  class HotelStarsReport < Report
    arel_tables :claims
    available_results :count
    attribute :intervals # example: { values: [0, 10, 20], names: ['0-10', '10-20'] }

    attr_accessible :intervals

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      unless intervals
        self.intervals = {
          values: ["1*", "2*", "3*", "4*", "5*"],
          names: ["*", "**", "***", "****", "*****"]
        }
      end
    end

    def interval_field(column, use_name = true)
      expr = ''
      intervals[:values].each_with_index do |value, i|
        res = use_name ? intervals[:names][i] : i
        expr += "WHEN (position(\'#{value}\' in #{column}) <> 0) THEN '#{res}' "
      end
      expr += "ELSE \'#{I18n.t("intervals.names.other")}\'"
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
            "#{interval_field('(claims.hotel)')} AS name",
            claims[:id].count.as('count'),
            "#{interval_field('(claims.hotel)', false)} AS interval"
          )
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .group('name', 'interval')
          .order('interval')
      end
  end
end
