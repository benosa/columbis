module Boss
  class ClientsBaseReport < Report
    arel_tables :payments, :claims
    available_results :count, :amount
    attribute :intervals

    attr_accessible :intervals

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      unless intervals
        self.intervals = {
          :amount => [ {procent: 0.80, name: "80%"},
                       {procent: 0.95, name: "15%"},
                       {procent: 1, name: "05%"}
                     ],
          :payer_id => [ {procent: 0.50, name: "50%"},
                         {procent: 0.80, name: "30%"},
                         {procent: 1, name: "20%"}
                       ]
        }
      end
      
      intervals.each do |interval|
        interval[1].each do |i|
          i[:name] = I18n.t(".clientsbase_report." + interval[0].to_s, value: i[:name])
        end
      end
    end

    def prepare(options = {})
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:amount]  = build_result(query: amount_query,  typecast: {amount: :to_i})
      self
    end

    def interval_field(column, foo, sort)
      expr = ''
      intervals[column].slice(0..(intervals[column].length-2)).each do |interval|
        expr += "WHEN #{foo}(#{column}) over(order by amount #{sort} rows unbounded preceding) <= #{interval[:procent]} * #{foo}(#{column}) over() THEN '#{interval[:name]}' "
      end
      expr += "ELSE '#{intervals[column].last[:name]}'"
      "(CASE #{expr} END)"
    end

    def bar_settings(factor, data)
      if factor == :amount
        title = "#{I18n.t('report.amount')}, #{I18n.t('rur')}"
        ytitle = I18n.t('rur')
      elsif factor == :count
        title = I18n.t('report.tourist_quantity')
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
        title = I18n.t('report.tourist_quantity')
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
            payments[:payer_id],
            payments[:amount].sum.as('amount')
          )
          .join(claims, Arel::Nodes::OuterJoin).on(claims[:id].eq(payments[:claim_id]))
          .where(claims[:excluded_from_profit].eq(false))
          .where(payments[:payer_type].eq('Tourist'))
          .where(payments[:recipient_id].eq(company.id))
          .where(payments[:recipient_type].eq('Company'))
          .where(payments[:date_in].gteq(start_date).and(payments[:date_in].lteq(end_date)))
          .where(payments[:approved].eq(true).and(payments[:canceled].eq(false)))
          .group(payments[:payer_id])
          .as("t")
      end

      def count_query
        query = payments.project(
            "payer_id",
            "#{interval_field(:amount, "sum", "desc")} as name",
            )
          .from(base_query)
          .as("count")

        payments.project( "count(payer_id)", "name" )
          .from(query)
          .group("name")
          .order("name")
      end

      def amount_query
        query = payments.project(
            "amount",
            "#{interval_field(:payer_id, "count", "asc")} as name",
            )
          .from(base_query)
          .as("amount")

        payments.project( "sum(amount) as amount", "name" )
          .from(query)
          .group("name")
          .order("name")
      end
  end
end













