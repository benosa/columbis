# -*- encoding : utf-8 -*-
module Boss
  class IncomeReport < Report

    arel_tables :payments, :offices
    available_results :amount

    def prepare(options = {})
      @results[:amount] = build_result(query: amount_query, typecast: {amount: :to_f, timestamp: :to_i})
      @results[:offices] = build_result(query: offices_query, typecast: {amount: :to_f, timestamp: :to_i})
      self
    end

    def line_settings(factor, data)
      title = I18n.t('report.amount')
      ytitle = I18n.t('rur')

      settings = {
        chart: {
          zoomType: 'x'
        },
        title: {
          text: title
        },
        xAxis: {
          type: 'datetime',
          maxZoom: 15 * 24 * 3600000 # fifteen days
        },
        yAxis: {
          title: {
            text: ytitle
          }
        },
        series: [{
          name: title,
          # pointInterval: 24 * 3600000,
          data: data.map{ |o| [o['timestamp'] * 1000, o[factor.to_s]] }
        }]
      }.to_json
    end

    private

      def base_query
        payments.project("EXTRACT(EPOCH FROM payments.date_in) AS timestamp", payments[:amount].sum.as('amount'))
          .where(payments[:company_id].eq(company.id))
          .where(payments[:recipient_type].eq('Company'))
          .where(payments[:approved].eq(true))
          .where(payments[:canceled].eq(false))
          .where(payments[:date_in].gteq(start_date))
          .where(payments[:date_in].lteq(end_date))
      end

      def amount_query
        # base_query.project(payments[:date_in].as('date'), payments[:amount].sum.as('amount'))
        base_query
          .group('timestamp')
          .order('timestamp')
      end

      def offices_query
        base_query.project(payments[:office_id], offices[:name].as('office'))
          .join(offices).on(payments[:office_id].eq(offices[:id]))
          .group(payments[:office_id], 'timestamp')
          .order(payments[:office_id], 'timestamp')
      end

  end
end