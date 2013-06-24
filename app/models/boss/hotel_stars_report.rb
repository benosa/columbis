module Boss
  class HotelStarsReport < Report
    arel_tables :claims
    available_results :count

    def interval_field(column, use_name = true)
      expr = ''
      ["1*", "2*", "3*", "4*", "5*"].each do |value|
        expr += "WHEN (position(\'#{value}\' in #{column}) <> 0) THEN '#{value}' "
      end
      expr += "ELSE \'#{I18n.t("intervals.names.other")}\'"
      expr.blank? ? column : "(CASE #{expr} END)"
    end

    def prepare(options = {})
      @results[:count] = build_result(query: base_query, typecast: {count: :to_i})
      self
    end

    def bar_settings(data)
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
          data: data.map{ |o| o["count"] }
        }]
      }.to_json
    end

    def pie_settings(data)
      title = I18n.t('report.claim_quantity')

      settings = {
        title: {
          text: title
        },
        series: [{
          type: 'pie',
          name: title,
          data: data.map{ |o| [o['name'], o["count"]] }
        }]
      }.to_json
    end

    private

      def base_query
        claims.project(
            "#{interval_field('(claims.hotel)')} AS name",
            claims[:id].count
          )
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:canceled].eq(false))
          .group('name')
          .order('name')
      end
  end
end