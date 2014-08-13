module Boss
  class SalesFunnelReport < Report
    arel_tables :tourists, :claims, :tourist_claims
    available_results :count

    def prepare(options = {})
      middle  = build_result(query: middle_query,  typecast: {count: :to_i, name: :to_s})
      down  = build_result(query: down_query,  typecast: {count: :to_i, name: :to_s})
      canceled  = build_result(query: canceled_query,  typecast: {count: :to_i, name: :to_s})
      clients = build_result(query: clients_query,  typecast: {state: :to_s, count: :to_i})
      @results[:count] = []

      clients.data.each do |state|
        if state['state'].to_s != ''
          @results[:count].push("name" => I18n.t(".salesfunnel_report.#{state['state']}"), "count" => state["count"].to_i)
        end
      end

      [middle, down, canceled].each do |data|
        @results[:count].push(data.map { |o| {"name" => o["name"], "count" => o["count"]}}.first)
      end

      @count = 0
      @results[:count].each {|e| @count += e['count'].to_i}
      @results[:count].each {|e| e['name'] += " #{((e['count'].to_f / @count.to_f) * 100).round(1)}%"}  if @count > 0
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
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:excluded_from_profit].eq(false))
      end

      def up_query
        tourists.project(tourists[:id].count, "'#{I18n.t('.salesfunnel_report.down')}' as name")
          .where(tourists[:company_id].eq(company.id))
          .where(tourists[:potential].eq(true))
      end

      def clients_query
        tourists.project(tourists[:state], tourists[:id].count)
          .where(tourists[:company_id].eq(company.id))
          .where(tourists[:potential].eq(true))
          .where(tourists[:created_at].gteq(start_date).and(tourists[:created_at].lteq(end_date)))
          .group(tourists[:state])
      end

      def middle_query
        base_query.project("'#{I18n.t('.salesfunnel_report.middle')}' as name")
          .where(claims[:canceled].eq(false))
          .where(claims[:closed].eq(false))
      end

      def down_query
        base_query.project("'#{I18n.t('.salesfunnel_report.up')}' as name")
          .where(claims[:canceled].eq(false))
          .where(claims[:closed].eq(true))
      end

      def canceled_query
        base_query.project("'#{I18n.t('.salesfunnel_report.canceled')}' as name")
          .where(claims[:canceled].eq(true))
      end
  end
end