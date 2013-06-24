# -*- encoding : utf-8 -*-
module Boss
  class NormalCheckReport < Report
    arel_tables :claims
    available_results :count
    
    def prepare(options = {})
      @results[:count]  = build_result(query: default_query,  typecast: {count: :to_f, amount: :to_f, date: :to_datetime})
      self
    end
    
    def spline_settings(data)
      settings = {
        title: {
          text: I18n.t('normalcheck_report.title')
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          title: {
            text: I18n.t('normalcheck_report.yaxis')
          }
        },
        series: [{
          name: I18n.t('normalcheck_report.info'),
          pointInterval: 7 * 24 * 3600 * 1000,
          data: data.map{ |o| [ o["date"].to_i * 1000, o["amount"]/o["count"]] }
        }]
      }.to_json
    end
    
    private
    
      def default_query
        claims.project(claims[:primary_currency_price].sum.as("amount"), claims[:id].count.as("count"), claims[:reservation_date].as("date"))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:canceled].eq(false))
          .group(:date)
          .order(:date)
      end
    
  end
end