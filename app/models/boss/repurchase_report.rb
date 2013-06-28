module Boss
  class RepurchaseReport < Report
    arel_tables :tourists, :payments
    available_results :count

    def prepare(options = {})
      @results[:count]  = build_result(query: base_query,  typecast: {count: :to_i})

      self
    end

    def bar_settings(factor, data)
      title = I18n.t('report.tourist_quantity')
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
      title = I18n.t('report.tourist_quantity')

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
        query = payments.project( payments[:id].count.as('number'), payments[:payer_id].as('payer_id') )
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .group('payer_id')
          .as('payments')
          
        tourists.project( tourists[:id].count.as('count'), query[:number].as('name') )
          .join(query).on(query[:payer_id].eq(tourists[:id]))
          .group(:number)
          .order('name')
      end
  end
end