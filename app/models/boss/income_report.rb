# -*- encoding : utf-8 -*-
module Boss
  class IncomeReport < Report
    VIEWS = %w(days months)

    attribute :view, default: 'days'
    attribute :office_filter
    attribute :manager_filter
    attribute :title
    attr_accessible :view, :office_filter, :manager_filter, :title

    arel_tables :payments, :offices, :claims, :users
    available_results :amount, :amount_offices, :amount_managers, :total, :total_offices, :total_managers
    
    def initialize(options = {})
      super
      @payment_type = options[:payment_type] ? options[:payment_type] : 'Company'
      @title = @payment_type == 'Company' ? 'Company' : 'Title'
    end

    def prepare(results = nil)
      results = [results] unless results.kind_of?(Array)
      if results.empty? or results.include?(:amount)
        @results[:amount] = build_result(query: amount_query, typecast: {amount: :to_f, timestamp: :to_i})
        @results[:total] = {
          'name' => I18n.t('report.total_for_period', start: I18n.l(start_date, format: :long), end: I18n.l(end_date, format: :long)),
          'amount' => @results[:amount].inject(0){ |total, row| total += row['amount'] }.round(2)
        }
      end
      if results.empty? or results.include?(:amount_offices)
        result = build_result(query: offices_query, typecast: {amount: :to_f, timestamp: :to_i})
        @results[:amount_offices] = result.group_by!('name').adjust_groups!(points: 'timestamp', factor: 'amount', defval: 0)
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
        @results[:amount_managers] = result.group_by!('name').adjust_groups!(points: 'timestamp', factor: 'amount', defval: 0)
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

    def area_settings(result)
      title = I18n.t(result != :amount ? "income_report.#{result}" : 'report.amount')
      title = "#{title}, #{I18n.t('rur')}"
      ytitle = I18n.t('rur')

      settings = {
        series: []
      }
      if result != :amount
        @results[result].each do |key, row|
          h = {
            name: key,
            data: row.map{ |o| [o['timestamp'] * 1000, o['amount']] }
          }
          h[:color] = row[0]['color'] if row[0] || row[0]['color']
          settings[:series] << h
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
        },
        tooltip: {
          borderColor: '#4572A7'
        }
      }.deep_merge(settings).to_json
    end

    def column_settings(result)
      title = I18n.t(result != :amount ? "income_report.#{result}" : 'report.amount')
      title = "#{title}, #{I18n.t('rur')}"
      ytitle = I18n.t('rur')

      settings = {
        series: []
      }
      if result != :amount
        @results[result].each do |key, row|
          h = {
            name: key,
            data: row.map{ |o| o['amount'] }
          }
          h[:color] = row[0]['color'] if row[0] || row[0]['color']
          settings[:series] << h
        end
        settings[:legend] = { enabled: true }
        settings[:xAxis] = {
          categories: @results[result].first[1].map{ |row| row['timestamp'] * 1000 }
        }
      else
        settings[:series] << {
          name: title,
          data: @results[result].map{ |o| o['amount'] }
        }
        settings[:xAxis] = {
          categories: @results[result].map{ |row| row['timestamp'] * 1000 }
        }
      end

      settings = {
        chart: {
          zoomType: 'x'
        },
        title: {
          text: title
        },
        yAxis: {
          title: {
            text: ytitle
          }
        },
        tooltip: {
          borderColor: '#4572A7'
        }
      }.deep_merge(settings).to_json
    end

    def bar_settings(result)
      title = I18n.t('report.totals_for_period', start: I18n.l(start_date, format: :long), end: I18n.l(end_date, format: :long))
      title = "#{title}, #{I18n.t('rur')}"
      ytitle = I18n.t('rur')

      settings = {
        title: {
          text: title
        },
        xAxis: {
          categories: @results[result].map{ |row| row['name'] }
        },
        yAxis: {
          title: {
            text: ytitle
          }
        },
        series: [{
          name: title,
          data: @results[result].map{ |row| row['amount'] }
        }]
      }.to_json
    end

    private

      def timestamp_field
        if view == 'months'
          "EXTRACT(EPOCH FROM date_trunc('month', payments.date_in))"
        else
          "EXTRACT(EPOCH FROM payments.date_in)"
        end
      end

      def base_query
        payments.project("#{timestamp_field} AS timestamp", payments[:amount].sum.as('amount'))
          .where(payments[:company_id].eq(company.id))
          .where(payments[:recipient_type].eq(@payment_type))
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
        query = base_query.project(offices[:id].as('office_id'), offices[:name].as('name'))
          .join(claims).on(payments[:claim_id].eq(claims[:id]))
          .join(offices).on(claims[:office_id].eq(offices[:id]))
          .group('timestamp', offices[:id])
          .order('timestamp', offices[:id])

        if office_filter
          query = query.where(offices[:id].in(office_filter))
        end
      end

      def managers_query
        query = base_query.project(users[:id].as('manager_id'), users[:color].as('color'),
        "(CASE WHEN users.first_name != '' OR users.last_name != '' THEN users.first_name || ' ' || users.last_name ELSE users.login END) AS name")
          .join(claims).on(payments[:claim_id].eq(claims[:id]))
          .join(users).on(claims[:user_id].eq(users[:id]))
          .group('timestamp', users[:id])
          .order('timestamp', users[:id])

        if manager_filter
          query = query.where(users[:id].in(manager_filter))
        end
      end

  end
end