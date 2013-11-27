module Boss
  class SalesFunnelReport < Report
    arel_tables :tourists, :claims, :tourist_claims
    available_results :count

    def prepare(options = {})
      up  = build_result(query: up_query,  typecast: {count: :to_i, name: :to_s})
      middle  = build_result(query: middle_query,  typecast: {count: :to_i, name: :to_s})
      down  = build_result(query: down_query,  typecast: {count: :to_i, name: :to_s})

      @results[:count] = []
      [up, middle, down].each do |data|
        @results[:count].push(data.map { |o| {"name" => o["name"], "count" => o["count"]}}.first)
      end

      self
    end

    def funnel_settings(data)
      settings = {
        chart: {
          width: 800,
          marginRight: 400
        },
        title: {
          text: '',
          marginRight: 0
        },
        series: [{
          name: I18n.t('report.tourist_quantity'),
          data: data.map{ |o| [o["name"], o["count"]] }
        }]
      }.to_json
    end

    private
      def base_query
        claims.project(tourist_claims[:tourist_id].count)
          .join(tourist_claims).on(tourist_claims[:claim_id].eq(claims[:id]))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:canceled].eq(false))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:excluded_from_profit].eq(false))
      end

      def up_query
        tourists.project(tourists[:id].count, "'#{I18n.t('.salesfunnel_report.down')}' as name")
          .where(tourists[:company_id].eq(company.id))
          .where(tourists[:potential].eq(true))
      end
      def middle_query
        base_query.project("'#{I18n.t('.salesfunnel_report.middle')}' as name")
          .where(claims[:closed].eq(false))
      end
      def down_query
        base_query.project("'#{I18n.t('.salesfunnel_report.up')}' as name")
          .where(claims[:closed].eq(true))
      end
  end
end