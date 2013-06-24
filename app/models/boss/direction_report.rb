# -*- encoding : utf-8 -*-
module Boss
  class DirectionReport < Report

    arel_tables :countries, :payments, :claims
    available_results :amount, :items, :total

    def prepare(options = {})
      amount_options = (options[:amount] || {}) unless options[:amount] === false
      items_options  = (options[:items] || {}) unless options[:items] === false

      # Amount data
      if amount_options
        @results[:amount] = build_result(query: amount_query(amount_options), typecast: {amount: :to_f})
      end

      # Items data
      if items_options
        @results[:items] = build_result(query: items_query(items_options), typecast: {items: :to_i})
      end

      # Total
      # @results[:total] = ReportResult.merge(self, @results[:amount], @results[:items]).sort!
      @results[:total] = build_result.merge(@results[:amount], @results[:items]).sort!

      self
    end

    def amount_compact
      amount.compact(columns: 'amount', name: I18n.t('direction_report.others'))
    end

    def items_compact
      items.compact(columns: 'items', name: I18n.t('direction_report.others'))
    end

    def bar_settings(factor, data)
      if factor == :amount
        title = "#{I18n.t('direction_report.amount')}, #{I18n.t('rur')}"
        ytitle = I18n.t('rur')
      elsif factor == :items
        title = I18n.t('direction_report.items')
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
        title = "#{I18n.t('direction_report.amount')}, #{I18n.t('rur')}"
      elsif factor == :items
        title = I18n.t('direction_report.items')
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
        countries.project([countries[:id], countries[:name]])
          .where(countries[:company_id].eq(company.id).or(countries[:common].eq(true)))
      end

      def amount_query(options = {})
        query = payments.project(payments[:claim_id], payments[:amount])
          .where(payments[:company_id].eq(company.id))
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_type].eq('Company')).where(payments[:recipient_id].eq(company.id))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .as('amount_query')

        if options.has_key?(:approved)
          query = query.where(payments[:approved].eq(options[:approved]))
        end

        claims_query = claims.project(claims[:id], claims[:country_id])
          .where(claims[:company_id].eq(company.id)) # .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .as('claims_query')

        query = base_query.project(query[:amount].sum.as('amount'))
                .join(claims_query).on(claims_query[:country_id].eq(countries[:id]))
                .join(query).on(query[:claim_id].eq(claims_query[:id]))
                .group(countries[:id])
                .order(order_expr 'SUM(amount_query."amount")')
        query
      end

      def items_query(options = {})
        query = claims.project(claims[:country_id], claims[:id].count.as('items'))
                .where(claims[:company_id].eq(company.id))
                .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
                .group(claims[:country_id])
                .as('items_query')

        query = base_query.project(query[:items])
                .join(query).on(query[:country_id].eq(countries[:id]))
                .order(order_expr 'items_query."items"')
        query
      end

  end
end