module Boss
  class PromotionChannelReport < Report
    arel_tables :claims, :payments
    available_results :count, :amount

    def initialize(attributes = nil, options = {})
      super

      @intervals = [ I18n.t('intervals.channels.default'),
                  I18n.t('intervals.channels.internet'),
                  I18n.t('intervals.channels.recommendations'),
                  I18n.t('intervals.channels.client'),
                  I18n.t('intervals.channels.tv'),
                  I18n.t('intervals.channels.magazines'),
                  I18n.t('intervals.channels.signboard')
                  ]
    end

    def interval_field(column)
      expr = ''
      @intervals.each do |value|
        expr += " WHEN (#{column} = '#{value}') THEN '#{value}' "
      end
      expr.blank? ? column : "(CASE #{expr} ELSE '#{I18n.t('intervals.channels.default')}' END)"
    end

    def prepare(options = {})
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:amount] = build_result(query: amount_query, typecast: {amount: :to_i})

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
      data = data_check(factor, data)

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
      data = data_check(factor, data)

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

      def data_check(factor, data)
        data = data.map{ |o| {'name' => o['name'], factor.to_s => o[factor.to_s]}}
        @intervals.each do |value|
          unless data.any?{|o| o['name'] == value }
            data.push({'name' => value, factor.to_s => 0})
          end
        end
        data
      end

      def base_query
        claims.project(
            "#{interval_field('claims.tourist_stat')} AS name"
          )
        .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
        .where(claims[:canceled].eq(false))
        .where(claims[:excluded_from_profit].eq(false))

      end

      def count_query
        base_query.project( claims[:id].count.as('count') )
          .group(:name)
          .order('count DESC')
      end

      def amount_query
        query = payments.project(payments[:claim_id], payments[:amount])
          .where(payments[:company_id].eq(company.id))
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_type].eq('Company')).where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .as('amount_query')

        base_query.project( query[:amount].sum.as('amount') )
          .join(query).on(query[:claim_id].eq(claims[:id]))
          .group(:name)
          .order('amount DESC')
      end
  end
end