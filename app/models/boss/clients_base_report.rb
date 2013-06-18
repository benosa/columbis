module Boss
  class ClientsBaseReport < Report
    arel_tables :tourist, :payments, :claims
    available_results :count, :amount

    def prepare(options = {})
      @results[:count]  = build_result(query: base_query,  typecast: {count: :to_i})

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
        payments.project( 
            payments[:payer_id].as('name'),
            payments[:amount].sum.as('amount')
          )
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .group(payments[:amount].desc)
      end
      
      def count_query
      end
      
      def amount_query
        
      end
      
      def over_query(procent, name)
        payments.project(payments[:payer_id], "sum(amount) over(order by amount desc rows unbounded preceding) <= #{procent} * sum(amount) over() as #{name}")
      end
  end
end


select payer_id, sum(amount) over(order by amount desc rows unbounded preceding) <= 0.8 * sum(amount) over() as is_top_user
from (select sum(amount) as amount, payer_id from payments group by 2) t













