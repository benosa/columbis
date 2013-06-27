# -*- encoding : utf-8 -*-
module Boss
  class NormalCheckReport < Report
    arel_tables :claims
    available_results :count
    attribute :view, default: 'days'

    attr_accessible :view

    VIEWS = %w(days months)

    def prepare(options = {})
      if view == 'days'
        @results[:count]  = build_result(query: default_query,  typecast: {count: :to_f, amount: :to_f, date: :to_datetime})
      else
        @results[:count]  = build_result(query: column_query,  typecast: {count: :to_f, amount: :to_f, month: :to_i})
      end
      self
    end

    def bar_settings(data)
      categories = data.map { |o| I18n.t("date.months")[o["month"] - 1] }
      xdata = data.map { |o| (o["amount"]/o["count"]).round 2 }

      settings = {
        title: {
          text: I18n.t('normalcheck_report.title')
        },
        xAxis: {
          categories: categories,
          labels: {
            formatter: nil
          }
        },
        yAxis: {
          title: {
            text: I18n.t('normalcheck_report.yaxis')
          },
          stackLabels: {
            enabled: true
          }
        },
        series: [{
          name: I18n.t('normalcheck_report.info'),
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

    def spline_settings(data)
      settings = {
        chart: {
          zoomType: 'x'
        },
        title: {
          text: I18n.t('normalcheck_report.title')
        },
        xAxis: {
          type: 'datetime',
          maxZoom: 15 * 24 * 3600000
        },
        yAxis: {
          title: {
            text: I18n.t('normalcheck_report.yaxis')
          }
        },
        series: [{
          name: I18n.t('normalcheck_report.info'),
          pointInterval: 7 * 24 * 3600 * 1000,
          data: data.map{ |o| [ o["date"].to_i * 1000, o["amount"]/o["count"]] }
        }]
      }.to_json
    end

    private

      def base_query
        claims.project(claims[:primary_currency_price].sum.as("amount"), claims[:id].count.as("count"))
          .where(claims[:company_id].eq(company.id))
          .where(claims[:reservation_date].gteq(start_date).and(claims[:reservation_date].lteq(end_date)))
          .where(claims[:canceled].eq(false))
      end

      def default_query
        base_query.project(claims[:reservation_date].as("date"))
          .group(:date)
          .order(:date)
      end

      def column_query
        base_query.project(
            "extract(epoch from date_trunc('month', claims.reservation_date)) as month_number",
            "extract(month from claims.reservation_date) as month"
          )
          .group(:month_number, :month)
          .order(:month_number)
      end

  end
end