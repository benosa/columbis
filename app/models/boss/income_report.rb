# -*- encoding : utf-8 -*-
module Boss
  class IncomeReport < Report

    arel_tables :payments, :offices, :claims, :users
    available_results :amount, :amount_offices, :amount_managers, :total, :total_offices, :total_managers

    def prepare(results = nil)
      results = [results] unless results.kind_of?(Array)
      if results.empty? or results.include?(:amount)
        @results[:amount] = build_result(query: amount_query, typecast: {amount: :to_f, timestamp: :to_i})
        @results[:total] = {
          'name' => I18n.t('income_report.income_for_period', start: I18n.l(start_date, format: :long), end: I18n.l(end_date, format: :long)),
          'amount' => @results[:amount].inject(0){ |total, row| total += row['amount'] }.round(2)
        }
      end
      if results.empty? or results.include?(:amount_offices)
        result = build_result(query: offices_query, typecast: {amount: :to_f, timestamp: :to_i})
        @results[:amount_offices] = result.group_by!('name').adjust_groups!(points: 'timestamp', factor: 'amount')
        total_data = @results[:amount_offices].inject([]) do |res, group|
          res << {
            'name' => group[0],
            'amount' => group[1].inject(0){ |total, row| total += row['amount'] }.round(2)
          }
        end
        @results[:total_offices] = build_result(data: total_data).sort!
      end
      if results.empty? or results.include?(:amount_managers)
        result = build_result(query: managers_query, typecast: {amount: :to_f, timestamp: :to_i})
        @results[:amount_managers] = result.group_by!('name').adjust_groups!(points: 'timestamp', factor: 'amount')
        total_data = @results[:amount_managers].inject([]) do |res, group|
          res << {
            'name' => group[0],
            'amount' => group[1].inject(0){ |total, row| total += row['amount'] }.round(2)
          }
        end
        @results[:total_managers] = build_result(data: total_data).sort!
      end
      self
    end

    def settings(result)
      title = I18n.t(result != :amount ? "income_report.#{result}" : 'report.amount')
      ytitle = I18n.t('rur')

      settings = {
        series: []
      }
      if result != :amount
        @results[result].each do |key, row|
          settings[:series] << {
            name: key,
            data: row.map{ |o| [o['timestamp'] * 1000, o['amount']] }
          }
        end
        settings[:legend] = { enabled: true }
      else
        settings[:series] << {
          name: title,
          data: @results[result].map{ |o| [o['timestamp'] * 1000, o['amount']] }
        }
      end

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
        }
      }.deep_merge(settings).to_json
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
        base_query.project(offices[:id].as('office_id'), offices[:name].as('name'))
          .join(claims).on(payments[:claim_id].eq(claims[:id]))
          .join(offices).on(claims[:office_id].eq(offices[:id]))
          .group('timestamp', offices[:id])
          .order('timestamp', offices[:id])
      end

      def managers_query
        base_query.project(users[:id].as('manager_id'), "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name")
          .join(claims).on(payments[:claim_id].eq(claims[:id]))
          .join(users).on(claims[:user_id].eq(users[:id]))
          .group('timestamp', users[:id])
          .order('timestamp', users[:id])
      end

  end
end