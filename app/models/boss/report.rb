# -*- encoding : utf-8 -*-
module Boss
  class Report
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    attr_accessor :company, :user, :name, :start_date, :end_date, :period

    validates :company, presence: true

    # Instance methods
    def initialize(attributes = {})
      attributes.each do |name, value|
        a = "#{name}="
        send(a, value) if respond_to?(a)
      end
      @start_date ||= Date.current.beginning_of_month
      @end_date ||= Date.current.end_of_month
    end

    def persisted?
      false
    end

    def order_expr(column)
      "(CASE WHEN #{column} IS NULL THEN 0 ELSE #{column} END) DESC"
    end

    def merge_results(*args)
      options = args.extract_options!
      return [] if args.compact.empty?

      first_arr = args[0].kind_of?(Array) ? args[0] : [args[0]]
      first_col = first_arr[0].kind_of?(Hash) ? (first_arr[0].key?('id') ? 'id' : first_arr[0].keys[0]) : first_arr[0]
      key_col = (options[:key] || first_col).to_s
      order_col = (options[:order] || first_col).to_s

      result_hash = {}
      args.each do |arg|
        arg = [arg].compact unless arg.kind_of?(Array)
        next if arg.empty?

        arg.each do |hash|
          key_val = hash[key_col]
          unless result_hash[key_val]
            result_hash[key_val] = hash.dup
          else
            hash.each { |col, val| result_hash[key_val][col] = val }
          end
        end
      end

      results = result_hash.values
      results.sort{ |r1, r2| r1[order_col] <=> r2[order_col] }
    end

    def typecast_results(arr, columns)
      arr.each do |row|
        columns.each do |column, args|
          args = [args] unless args.kind_of?(Array)
          column = column.to_s
          row[column] = row[column].send(*args)
        end
      end
    end

    def compact_results(arr, row_count, options = {})
      columns = (options[:columns].kind_of?(Array) ? options[:columns] : [options[:columns]]) || []
      if options[:name].kind_of?(Array)
        name_col, title = options[:name][0], options[:name][1]
      elsif options.key?(:name)
        name_col, title = 'name', options[:name]
      else
        name_col, title = 'name', I18n.t('reports.title.others')
      end

      results = arr[0, row_count - 1]

      last = { name_col => title }
      remains = arr.from(row_count)
      args = [:to_i]
      columns.each do |col|
        if col.kind_of?(Array)
          column, args = col[0], col.from(1)
        else
          column = col
        end
        last[column] = remains.inject(0){ |sum, row| sum + (row[column].kind_of?(Numeric) ? row[column] : row[column].send(*args)) }
      end
      results << last
    end

    # Report
    def operators(options = {})
      on_amount = options.has_key?(:amount) ? options[:amount] : true
      on_items = options.has_key?(:items) ? options[:items] : true
      order_by = options[:order] ? options[:order].to_sym : :amount
      row_count = (options[:rows].to_i if options[:rows]) || :all

      operators = Arel::Table.new(:operators)
      query = operators.project([operators[:id], operators[:name]])
              .where(operators[:company_id].eq(@company.id))
              # .group(operators[:id])

      results = {
        :amount => nil,
        :items => nil,
        :total => nil
      }

      # Amount data
      if on_amount
        payments = Arel::Table.new(:payments)
        amount_query = payments.project(payments[:recipient_id].as('operator_id'), payments[:amount].sum.as('amount'))
                .where(payments[:company_id].eq(@company.id))
                .where(payments[:recipient_type].eq('Operator'))
                .where(payments[:payer_type].eq('Company')).where(payments[:payer_id].eq(@company.id))
                .where(payments[:date_in].gteq(@start_date).and(payments[:date_in].lteq(@end_date)))
                .group(payments[:recipient_id])
                .as('amount_query')

        if options.has_key?(:approved)
          amount_query = amount_query.where(payments[:approved].eq(options[:approved]))
        end

        amount_query = query.dup.project(amount_query[:amount])
                .join(amount_query).on(amount_query[:operator_id].eq(operators[:id]))
                .order(order_expr 'amount_query."amount"')

        # Rails.logger.debug "amount_query: #{amount_query.to_sql}"
        amount_results = ActiveRecord::Base.connection.execute(amount_query.to_sql).to_a
        amount_results = typecast_results(amount_results, amount: :to_f)
        results[:amount] = if row_count == :all then amount_results else
          compact_results(amount_results, row_count, columns: 'amount', name: I18n.t('report.title.other_operators'))
        end
      end

      # Items data
      if on_items
        claims = Arel::Table.new(:claims)
        items_query = claims.project(claims[:operator_id], claims[:id].count.as('items'))
                .where(claims[:company_id].eq(@company.id))
                .where(claims[:reservation_date].gteq(@start_date).and(claims[:reservation_date].lteq(@end_date)))
                .group(claims[:operator_id])
                .as('items_query')

        items_query = query.dup.project(items_query[:items])
                .join(items_query).on(items_query[:operator_id].eq(operators[:id]))
                .order(order_expr 'items_query."items"')

        # Rails.logger.debug "items_query: #{items_query.to_sql}"
        items_results = ActiveRecord::Base.connection.execute(items_query.to_sql).to_a
        items_results = typecast_results(items_results, items: :to_i)
        results[:items] = if row_count == :all then items_results else
          compact_results(items_results, row_count, columns: 'items', name: I18n.t('report.title.other_operators'))
        end
      end

      # Operators total data
      results[:total] = merge_results(amount_results, items_results, order: order_by)
      results
    end

    def operators2(options = {})
      operators = Arel::Table.new(:operators)

      on_amount = options.has_key?(:amount) ? options[:amount] : true
      on_items = options.has_key?(:items) ? options[:items] : true
      order_by = options[:order] ? options[:order].to_sym : :amount

      query = operators.project([operators[:id], operators[:name]])
              .where(operators[:company_id].eq(@company.id))
              # .group(operators[:id])

      if on_amount
        payments = Arel::Table.new(:payments)
        amount_query = payments.project(payments[:recipient_id].as('operator_id'), payments[:amount].sum.as('amount'))
                .where(payments[:company_id].eq(@company.id))
                .where(payments[:recipient_type].eq('Operator'))
                .where(payments[:payer_type].eq('Company')).where(payments[:payer_id].eq(@company.id))
                .where(payments[:date_in].gteq(@start_date).and(payments[:date_in].lteq(@end_date)))
                .group(payments[:recipient_id])
                .as('amount_query')

        if options.has_key?(:approved)
          amount_query = amount_query.where(payments[:approved].eq(options[:approved]))
        end

        query.orders.clear
        query = query.project(amount_query[:amount])
                .join(amount_query, Arel::OuterJoin).on(amount_query[:operator_id].eq(operators[:id]))
        query = query.order(order_expr 'amount_query."amount"') if order_by == :amount
      end

      if on_items
        claims = Arel::Table.new(:claims)
        items_query = claims.project(claims[:operator_id], claims[:id].count.as('items'))
                .where(claims[:company_id].eq(@company.id))
                .where(claims[:reservation_date].gteq(@start_date).and(claims[:reservation_date].lteq(@end_date)))
                .group(claims[:operator_id])
                .as('items_query')

        query = query.project(items_query[:items])
                .join(items_query, Arel::OuterJoin).on(items_query[:operator_id].eq(operators[:id]))
        query = query.order(order_expr 'items_query."items"') if order_by == :items
      end

      # Filter empty results
      # query = query.having(Arel::Nodes::Sum.new([amount_query[:amount]]).gt(0).or(Arel::Nodes::Count.new([items_query[:items]]).gt(0)))
      filter = false
      if on_amount and on_items
        filter = query.grouping(amount_query[:amount].gt(0).or(items_query[:items].gt(0)))
      elsif on_amount
        filter = amount_query[:amount].gt(0)
      else
        filter = items_query[:items].gt(0)
      end
      query = query.where(filter) if filter

      # Default order
      query = query.order(operators[:name]) if query.orders.empty? # order_by == :operator

      Rails.logger.debug "query: #{query.to_sql}"
      result = ActiveRecord::Base.connection.execute(query.to_sql)
      result.to_a
    end

    def operators1(options = {})
      operators = Arel::Table.new(:operators)

      on_amount = options.has_key?(:amount) ? options[:amount] : true
      on_items = options.has_key?(:items) ? options[:items] : true

      query = operators.project([operators[:id], operators[:name]])
              .where(operators[:company_id].eq(@company.id))
              .group(operators[:id])
              .order(operators[:name])

      if options.has_key?(:approved)
        query = query.where(payments[:approved].eq(options[:approved]))
      end

      if on_amount
        payments = Arel::Table.new(:payments)
        query = query.project(payments[:amount].sum.as('amount'))
                .join(payments, Arel::OuterJoin).on(payments[:recipient_id].eq(operators[:id]))
                .where(payments[:company_id].eq(@company.id))
                .where(payments[:recipient_type].eq('Operator'))
                .where(payments[:payer_type].eq('Company')).where(payments[:payer_id].eq(@company.id))
                .where(payments[:date_in].gteq(@start_date).and(payments[:date_in].lteq(@end_date)))
        query.orders.clear
        query = query.order('amount DESC')
      end

      if on_items
        claims = Arel::Table.new(:claims)
        query = query.project(claims[:id].count.as('items'))
                .join(claims, Arel::OuterJoin).on(claims[:operator_id].eq(operators[:id]))
                .where(claims[:company_id].eq(@company.id))
                .where(claims[:reservation_date].gteq(@start_date).and(claims[:reservation_date].lteq(@end_date)))
        query = query.order('items DESC') if query.orders.empty?
      end

      Rails.logger.debug "query1: #{query.to_sql}"
      result = ActiveRecord::Base.connection.execute(query.to_sql)
      result.to_a
    end

    def operators_claims(options = {})
      claims = Arel::Table.new(:claims)
      operators = Arel::Table.new(:operators)
      payments = Arel::Table.new(:payments)
      query = operators.project([operators[:id], operators[:name], payments[:amount].sum.as('amount')])
              .join(claims).on(claims[:operator_id].eq(operators[:id]))
              .join(payments, Arel::OuterJoin).on(payments[:claim_id].eq(claims[:id]))
              .where(operators[:company_id].eq(@company.id))
              .where(payments[:payer_type].eq('Company')).where(payments[:payer_id].eq(@company.id))
              .group(operators[:id])
              .order('amount DESC', operators[:name])

      if options.has_key?(:approved)
        query = query.where(payments[:approved].eq(options[:approved]))
      end

      Rails.logger.debug "query: #{query.to_sql}"
      result = ActiveRecord::Base.connection.execute(query.to_sql)
      result.to_a
    end

    # Class methods
    class << self
    end

  end
end