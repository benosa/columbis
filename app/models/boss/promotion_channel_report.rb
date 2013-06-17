module Boss
  class PromotionChannelReport < Report
    arel_tables :claims, :payments
    available_results :count, :amount, :total
    attribute :intervals

    attr_accessible :intervals

    def interval_field(column, use_name = true)
      expr = ''
      intervals[:values].each_with_index do |value, i|
        expr += ' WHEN ('
        res = use_name ? intervals[:names][i] : i
        value.each do |v|
          expr += " (#{column} LIKE '#{v}') "
          unless value.last == v
            expr += " OR "
          end
        end
        expr += ") THEN '#{res}' "
      end
      expr.blank? ? column : "(CASE #{expr} END)"
    end

    def prepare(options = {})
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:amount] = build_result(query: amount_query, typecast: {amount: :to_i})
      @results[:total]  = build_result.merge( @results[:amount], @results[:count] ).sort!

      self
    end

    def bar_settings(factor, data)      
      if factor == :amount
        title = "#{I18n.t('report.amount')}, #{I18n.t('rur')}"
        ytitle = I18n.t('rur')
      elsif factor == :count
        title = I18n.t('report.claim_quantity')
        ytitle = I18n.t('report.pcs')
      end

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
      if factor == :amount
        title = "#{I18n.t('report.amount')}, #{I18n.t('rur')}"
      elsif factor == :count
        title = I18n.t('report.claim_quantity')
      end

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
            "#{interval_field('claims.tourist_stat')} AS name",
            "#{interval_field('claims.tourist_stat', false)} AS interval"
          )
      end
      
      def count_query
        base_query.project( claims[:id].count.as('count') )
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .group('name', 'interval')
          .order('count')
      end
      
      def amount_query
        claims_query = base_query
        query = payments.project(payments[:claim_id], payments[:amount])
          .where(payments[:company_id].eq(company.id))
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_type].eq('Company')).where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .as('amount_query')
        
        base_query.project( query[:amount].sum.as('amount') )
          .join(query).on(query[:claim_id].eq(claims[:id]))
          .group('name', 'interval')
          .order('amount')
      end
  end
end