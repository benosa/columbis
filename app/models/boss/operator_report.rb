# -*- encoding : utf-8 -*-
module Boss
  class OperatorReport < Report

    arel_tables :operators, :payments, :claims, :company_operators
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

      # Total data
      # @results[:total] = ReportResult.merge(self, @results[:amount], @results[:items]).sort!
      @results[:total] = build_result.merge(@results[:amount], @results[:items]).sort!

      self
    end

    def amount_compact
      amount.compact(columns: 'amount', name: I18n.t('operator_report.others'))
    end

    def items_compact
      items.compact(columns: 'items', name: I18n.t('operator_report.others'))
    end

    def bar_settings(factor, data)
      if factor == :amount
        title = "#{I18n.t('operator_report.amount')}, #{I18n.t('rur')}"
        ytitle = I18n.t('rur')
      elsif factor == :items
        title = I18n.t('operator_report.items')
        ytitle = I18n.t('report.pcs')
      end

      settings = {
        title: {
          text: title
        },
        # subtitle: {
        #   text: row_count > 0 ? I18n.t('operator_report.first_operators', count: row_count) : I18n.t('operator_report.all_operators')
        # },
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
        title = "#{I18n.t('operator_report.amount')}, #{I18n.t('rur')}"
      elsif factor == :items
        title = I18n.t('operator_report.items')
      end

      settings = {
        title: {
          text: title
        },
        # subtitle: {
        #   text: row_count > 0 ? I18n.t('operator_report.first_operators', count: row_count) : I18n.t('operator_report.all_operators')
        # },
        series: [{
          type: 'pie',
          name: title,
          data: data.map{ |o| [o['name'], o[factor.to_s]] }
        }]
      }.to_json
    end

    private

      def base_query
        operators.project([operators[:id], operators[:name]])
          .join(company_operators).on(company_operators[:operator_id].eq(operators[:id]).and(company_operators[:company_id].eq(company.id)))
          #.where(operators[:company_id].eq(company.id))
          #.group(operators[:id])
      end

      def amount_query(options = {})
        query = claims.project(claims[:operator_id].as('operator_id'), claims[:primary_currency_operator_price].sum.as('amount'))
                .where(claims[:excluded_from_profit].eq(false))
                .where(claims[:canceled].eq(false))
                .where(claims[:company_id].eq(company.id))
                .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
                .group(claims[:operator_id])
                .as('amount_query')

       # if options.has_key?(:approved)
         # query = query.where(payments[:approved].eq(options[:approved]))
       # end

        query = base_query.project(query[:amount])
                .join(query).on(query[:operator_id].eq(operators[:id]))
                .order(order_expr 'amount_query."amount"')

        query
      end

      def items_query(options = {})
        query = claims.project(claims[:operator_id], claims[:id].count.as('items'))
                .where(claims[:company_id].eq(company.id))
                .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
                .where(claims[:canceled].eq(false))
                .where(claims[:excluded_from_profit].eq(false))
                .group(claims[:operator_id])
                .as('items_query')

        query = base_query.project(query[:items])
                .join(query).on(query[:operator_id].eq(operators[:id]))
                .order(order_expr 'items_query."items"')
        # Rails.logger.debug "query: #{query.to_sql}"
        query
      end

  end
end