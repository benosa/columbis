module Boss
  class RepurchaseReport < Report
    arel_tables :tourists, :payments, :claims
    available_results :count, :total
    attribute :minim, default: 3

    attr_accessible :minim
    attr_accessible :selects

    def prepare(options = {})
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:total]  = build_result(query: total_query(options[:dir]),  typecast: {count: :to_i}).sort!

      @selects = @results[:count].map{|o| o["name"].to_s}

      self
    end

    def bar_settings(factor, data)
      title = I18n.t('report.tourist_quantity')
      ytitle = I18n.t('report.pcs')
      xtitle = I18n.t('boss.reports.repurchase.xtitle')

      settings = {
        title: {
          text: title
        },
        xAxis: {
          categories: data.map{ |o| o['name'] },
          title: {
            text: xtitle
          }
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
      title = I18n.t('.repurchase_report.pie_title')

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
        payments.project( payments[:id].count.as('number'), payments[:payer_id].as('payer_id') )
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .group(:payer_id, :claim_id)
          .as('payments')
      end

      def total_query(dir)
        if minim == 0
          min = 3
        else
          min = minim
        end
        query = base_query
        ret = tourists.project(query[:number], query[:payer_id], tourists[:first_name], tourists[:last_name], tourists[:middle_name])
          .join(query).on(query[:payer_id].eq(tourists[:id]))
          .where(query[:number].gteq(min))
          .take(100)
        if dir == "asc" or dir == "desc"
          ret.order("number #{dir}")
        end
        ret
      end

      def count_query
        query = base_query
        tourists.project( tourists[:id].count.as('count'), query[:number].as('name') )
          .join(query).on(query[:payer_id].eq(tourists[:id]))
          .group(:name)
          .order(:name)
      end
  end
end