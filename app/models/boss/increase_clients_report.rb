module Boss
  class IncreaseClientsReport < Report
    arel_tables :tourists
    available_results :count
    attribute :year
    attr_accessible :year

    def prepare(options = {})
      @results[:count]  = build_result(query: base_query,  typecast: {count: :to_f, month: :to_i})
      self
    end

    def line_settings(data)
      categories = data.map { |o| I18n.t("date.months")[o["month"] - 1] }
      xdata = data.map { |o| o["count"] }

      xdata = xdata.each_with_index.map do |x, i|
        xd = i==0 ? x/x : x/xdata[i-1]
        cat = i==0 ? categories[i] : "#{categories[i]}/#{categories[i-1]}"
        [cat, (xd.round(2)*100).to_i]
      end

      settings = {
        chart: {
          zoomType: 'x'
        },
        title: {
          text: I18n.t('incraseclients_report.title')
        },
        xAxis: {
          categories: categories,
          maxZoom: 1,
          tickmarkPlacement: 'on',
          startOnTick: false
        },
        yAxis: {
          min: 0,
          title: {
            text: I18n.t('incraseclients_report.yaxis')
          }
        },
        series: [{
          name: I18n.t('incraseclients_report.yaxis'),
          data: xdata,
          pointStart: 0
        }],
        tooltip: {
            formatter: nil,
            valueSuffix: '%'
        }
      }.to_json
    end

    def bar_settings(data)
      categories = data.map { |o| I18n.t("date.months")[o["month"] - 1] }
      xdata = data.map { |o| o["count"] }

      settings = {
        title: {
          text: I18n.t('incraseclients_report.count_title')
        },
        xAxis: {
          categories: categories,
          labels: {
            formatter: nil
          }
        },
        yAxis: {
          title: {
            text: I18n.t('report.tourist_quantity')
          },
          stackLabels: {
            enabled: true
          }
        },
        series: [{
          name: I18n.t('report.tourist_quantity'),
          data: xdata
        }],
        tooltip: {
            formatter: nil
        },
        plotOptions: {
          column: {
            stacking: 'normal'
          }
        }
      }.to_json
    end

    private

      def base_query
        y = year ? year : Time.zone.now.year

        @end_date = "31.12.#{y}".to_datetime
        @start_date = "1.1.#{y}".to_datetime

        tourists.project( tourists[:id].count.as("count"),
            'extract(month from created_at) AS month'
          )
          .where(tourists[:company_id].eq(company.id))
          .where(tourists[:created_at].gteq(@start_date).and(tourists[:created_at].lteq(@end_date)))
          .group(:month)
          .order(:month)
      end
  end
end












