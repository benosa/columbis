# -*- encoding : utf-8 -*-
module Boss
  class IncomeIntervalReport < DateIntervalReport

    arel_tables :payments
    available_results :amount, :total

    def prepare(options = {})
      # current_res = build_result(query: current_query, typecast: {interval: :to_i, amount: :to_f})
      # prev_res = build_result(query: prev_query, typecast: {interval: :to_i, prev_amount: :to_f})
      # @results[:amount] = build_result.merge(current_res, prev_res, key: 'interval').sort!(col: 'interval', dir: :asc)
      # @results[:amount].data.delete_if{ |row| row['interval'] === 0 }.each do |row|
      #   row['percent'] = (row['amount'] - row['prev_amount']) / row['amount'] * 100 unless row['amount'] === 0
      #   row['percent'] = 0 if row['amount'] === 0
      # end
      unless options[:by_step]
        current_date_ranges = ranges_from_end_date
        current_res = build_result(query: query(current_date_ranges), typecast: {interval: :to_i, amount: :to_f})
        prev_date_ranges = ranges_from_end_date(true)
        prev_res = build_result(query: query(prev_date_ranges, 'prev_amount'), typecast: {interval: :to_i, prev_amount: :to_f})
        @results[:amount] = build_result.merge(current_res, prev_res, key: 'interval').sort!(col: 'interval', dir: :asc)
        @results[:amount].each do |row|
          row['percent'] = (row['amount'] - row['prev_amount']) / row['amount'] * 100 unless row['amount'] === 0
          row['percent'] = 0 if row['amount'] === 0
        end
        total = build_result(query: total_query, typecast: {amount: :to_f}).data
        @results[:total] = !total.empty? ? total.first['amount'] : 0
      else
        ranges = ranges_by_step_from_end_date(7, 7)
        @results[:amount] = build_result(query: by_step_query(ranges), typecast: {interval: :to_i, amount: :to_f}).sort!(col: 'interval', dir: :desc)
        @results[:amount].each do |row|
          row['date'] = I18n.l ranges[row['interval']].last, format: :short_with_month_name
        end
      end
      self
    end

    def bar_settings(data)
      # if factor == :amount
      #   title = "#{I18n.t('operator_report.amount')}, #{I18n.t('rur')}"
      #   ytitle = I18n.t('rur')
      # elsif factor == :items
      #   title = I18n.t('operator_report.items')
      #   ytitle = I18n.t('report.pcs')
      # end
      ytitle = I18n.t('rur')

      settings = {
        chart: {
          type: 'column'
        },
        title: false,
        # subtitle: {
        #   text: row_count > 0 ? I18n.t('operator_report.first_operators', count: row_count) : I18n.t('operator_report.all_operators')
        # },
        xAxis: {
          categories: data.map{ |o| o['date'] }
        },
        yAxis: {
          title: {
            text: ytitle
          }
        },
        series: [{
          # name: title,
          data: data.map{ |o| o['amount'] }
        }]
      }.to_json
    end

    private

      def base_query(options = {})
        start_date = options[:start_date] || self.start_date
        end_date = options[:end_date] || self.end_date
        payments
          .where(payments[:company_id].eq(company.id))
          .where(payments[:recipient_type].eq('Company'))
          .where(payments[:approved].eq(true))
          .where(payments[:canceled].eq(false))
          .where(payments[:date_in].gt(start_date))
          .where(payments[:date_in].lteq(end_date))
      end

      def query(ranges, factor_alias = 'amount')
        full_query = false
        ranges.each do |value, range|
          query = base_query(start_date: range.first, end_date: range.last)
            .project("#{value} AS interval", payments[:amount].sum.as(factor_alias))
            .group('interval')
          unless full_query
            full_query = query.to_sql
          else
            full_query += " UNION #{query.to_sql}"
          end
        end
        full_query
      end

      def by_step_query(ranges)
        base_query(start_date: ranges.last.first)
          .project("#{ranges_field('payments.date_in', ranges)} AS interval", payments[:amount].sum.as('amount'))
          .group('interval')
      end

      def current_query
        base_query.project("#{all_intervals_field('payments.date_in')} AS interval", payments[:amount].sum.as('amount'))
          .group('interval')
      end

      def prev_query
        base_query.project("#{all_intervals_field('payments.date_in', true)} AS interval", payments[:amount].sum.as('prev_amount'))
          .group('interval')
      end

      def total_query
        payments.project(payments[:amount].sum.as('amount'))
      end

  end
end