module Boss
  class IncreaseClientsReport < Report
    arel_tables :tourists
    available_results :count

    def prepare(options = {})
      @results[:count]  = build_result(query: base_query,  typecast: {count: :to_f, month: :to_i})
      self
    end

    def line_settings(data)
      categories = data.each_with_index.map { |o| I18n.t("date.months")[o["month"] - 1] }
      xdata = data.map { |o| o["count"] }
      
      xdata = xdata.each_with_index.map do |x, i|
        x = i==0 ? x/x : x/xdata[i-1]
        x = x.round 2
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
          maxZoom: 1 
        },
        yAxis: {
          title: {
            text: I18n.t('incraseclients_report.yaxis')
          }
        },
        series: [{
          name: I18n.t('incraseclients_report.yaxis'),
          data: xdata
        }],
        tooltip: {
            formatter: nil
        }
      }.to_json
    end
    
    def bar_settings(data)
      
      settings = {
        title: {
          text: I18n.t('incraseclients_report.count_title')
        },
        xAxis: {
          categories: data.each_with_index.map { |o| I18n.t("date.months")[o["month"] - 1] }
        },
        yAxis: {
          title: {
            text: I18n.t('report.tourist_quantity')
          }
        },
        series: [{
          name: I18n.t('report.tourist_quantity'),
          data: data.map { |o| o["count"] }
        }],
        tooltip: {
            formatter: nil
        }
      }.to_json
    end

    private

      def base_query
        tourists.project( tourists[:id].count.as("count"), "extract(month from \"tourists\".\"created_at\") as month" )
          .where(tourists[:company_id].eq(company.id))
          .where(tourists[:created_at].gteq(start_date).and(tourists[:created_at].lteq(end_date)))
          .group(:month)
          .order(:month)
      end
  end
end













