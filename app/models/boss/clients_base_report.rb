module Boss
  class ClientsBaseReport < Report
    arel_tables :payments
    available_results :count, :amount

    def prepare(options = {})
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:amount]  = build_result(query: amount_query,  typecast: {amount: :to_i})
      self
    end

    def bar_settings(factor, data)      
      if factor == :amount
        title = "#{I18n.t('report.amount')}, #{I18n.t('rur')}"
        ytitle = I18n.t('rur')
      elsif factor == :count
        title = I18n.t('report.tourist_quantity')
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
        title = I18n.t('report.tourist_quantity')
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
        payments.project( 
            payments[:payer_id],
            payments[:amount].sum.as('amount')
          )
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .group(payments[:payer_id])
          .as("t")
      end
      
      def count_query
        query = payments.project(
            "payer_id",
            "(CASE
              WHEN sum(amount) over(order by amount desc rows unbounded preceding) <= 0.8 * sum(amount) over() THEN '80% выручки'
              WHEN sum(amount) over(order by amount desc rows unbounded preceding) <= 0.95 * sum(amount) over() THEN '15% выручки'
              ELSE '05% выручки'
            END) as name",
            )
          .from(base_query)
          .as("count")
        
        payments.project( "count(payer_id)", "name" )
          .from(query)
          .group("name")
          .order("name")
      end
      
      def amount_query
        query = payments.project(
            "amount",
            "(CASE
              WHEN count(payer_id) over(order by amount asc rows unbounded preceding) <= 0.5 * count(payer_id) over() THEN '50% клиентов'
              WHEN count(payer_id) over(order by amount asc rows unbounded preceding) <= 0.8 * count(payer_id) over() THEN '30% клиентов'
              ELSE '20% клиентов'
            END) as name",
            )
          .from(base_query)
          .as("amount")
        
        payments.project( "sum(amount) as amount", "name" )
          .from(query)
          .group("name")
          .order("name")
      end
  end
end













