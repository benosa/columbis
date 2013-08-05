module Boss
  class ClientsBaseReport < Report
    arel_tables :payments, :claims, :tourists
    available_results :count, :amount, :amount80, :amount15, :amount5
    attribute :intervals

    attr_accessible :intervals

    def initialize(attributes = nil, options = {})
      super

      # Default intervals
      unless intervals
        self.intervals = {
          :amount => [ {procent: 0.80, name: "0.80"},
                       {procent: 0.95, name: "0.15"},
                       {procent: 1, name: "0.05"}
                     ],
          :payer_id => [ {procent: 0.50, name: "0.50"},
                         {procent: 0.80, name: "0.30"},
                         {procent: 1, name: "0.20"}
                       ]
        }
      end
    end

    def prepare(options = {})
      self.sort_dir = "desc" if !(options[:sort_dir] || options[:dir] || self.sort_dir)
      self.sort_col = "amount" if !(options[:sort_col] || options[:col] || self.sort_col)
      @results[:count]  = build_result(query: count_query,  typecast: {count: :to_i})
      @results[:amount] = build_result(query: amount_query,  typecast: {amount: :to_i})
      payers            = build_result(query: payer_query,  typecast: {amount: :to_i}).sort!

      @results[:count].data.each{ |d| d['name'] = I18n.t(".clientsbase_report.count", value: to_procent(d['name'])) }
      @results[:amount].data.each{ |d| d['name'] = I18n.t(".clientsbase_report.amount", value: to_procent(d['name'])) }

      @results[:amount80] = []
      @results[:amount15] = []
      @results[:amount5] = []
      payers.data.each do |payer|
        case payer['name']
        when "0.80"
          @results[:amount80] << payer
        when "0.15"
          @results[:amount15] << payer
        when "0.05"
          @results[:amount5] << payer
        end
      end
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
      sum = data.inject(0) {|sum, x| sum.to_f + x[factor.to_s].to_f }
      ytitle = '%'
      if factor == :amount
        title = I18n.t('.clientsbase_report.amount_percent')
      elsif factor == :count
        title = I18n.t('.clientsbase_report.count_percent')
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
        plotOptions: {
          column: {
            dataLabels: {
              enabled: true
            }
          }
        },
        tooltip: {
          valueSuffix: ' %',
          formatter: ""
        },
        series: [{
          name: title,
          data: data.map{ |o| (o[factor.to_s].to_f * 100 / sum).round(2) }
        }]
      }.to_json
    end

    private

      def base_query
        payments.project( payments[:payer_id], payments[:amount].sum.as('amount') )
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

      def payer_query
        query = payments.project(
            "amount",
            "payer_id",
            "#{interval_field(:amount, "sum", "desc")} as name",
            )
          .from(base_query)
          .as("amount")

        payers = payments.project( "sum(amount) as amount", "name", "payer_id" )
          .from(query)
          .group("name", "payer_id")
          .order("name")
          .as('payers')

        tourists.project(tourists[:last_name], tourists[:first_name], tourists[:middle_name],
            payers[:amount], payers[:name])
          .join(payers).on(payers[:payer_id].eq(tourists[:id]))
      end

      def to_procent(float_string)
        (float_string.to_f.round(2)*100).to_i.to_s << '%'
      end
  end
end













