# -*- encoding : utf-8 -*-
module Boss
  class WidgetCell < Cell::Rails
    append_view_path 'app/views'

    def factor_income(options = {})
      @widget = Widget.factor(title: 'Доход')
      @report = IncomeIntervalReport.new(report_options options).prepare
      IncomeIntervalReport.new(report_options options).prepare(by_step: true)

      report_data = @report.results[:amount].data
      data = Array.new(4){ Array.new(3) }
      report_data.each_with_index do |r, i|
        data[0] << interval_to_human(r['interval'])
        data[1] << number_to_human(r['amount'], units: :short_units)
        data[2] << percent_to_sign(r['percent'])
        data[3] << number_to_percentage(r['percent'].abs)
      end
      @widget.data = data

      @widget.total = total_data @report.results[:total], {
        text: '(по данным подтвержденных оплат активных и завершенныx броней)',
        number_to_human: { units: :short_amount }
      }

      # total = @report.results[:total]
      # total_str = number_to_human(total)
      # total = total_str.gsub(/[^\d,]+/, '')
      # total_units = total_str.sub(total, '').strip
      # @widget.total = {
      #   title: 'Всего',
      #   data: "#{total} <span>#{total_units}<span/>".html_safe,
      #   text: '(по данным подтвержденных оплат не анулированных заявок)'.html_safe
      # }

      # render view: "_#{@widget[:view]}", locals: { widget: @widget }
      render partial: "boss/widgets/#{@widget[:view]}", locals: { widget: @widget }
    end

    def chart_income(options = {})
      @widget = Widget.small_chart(title: 'Доход (динамика по неделям)')
      @report = IncomeIntervalReport.new(report_options options).prepare(by_step: true)
      render partial: "boss/widgets/#{@widget[:view]}", locals: { widget: @widget, report: @report, data: @report.results[:amount].data, chart_id: 'chart_income' }
    end

    def factor_claims(options = {})
      @widget = Widget.factor(title: 'Брони')
      @report = ClaimIntervalReport.new(report_options options).prepare

      report_data = @report.results[:count].data
      data = Array.new(4){ Array.new(3) }
      report_data.each_with_index do |r, i|
        data[0] << interval_to_human(r['interval'])
        data[1] << number_to_human(r['count'], units: :short_units, precision: 0)
        data[2] << percent_to_sign(r['percent'])
        data[3] << number_to_percentage(r['percent'].abs)
      end
      @widget.data = data

      @widget.total = total_data @report.results[:total], {
        text: '(данные по активным и завершенным броням)',
        number_to_human: { units: :short_items, precision: 0 }
      }

      # render view: "_#{@widget[:view]}", locals: { widget: @widget }
      render partial: "boss/widgets/#{@widget[:view]}", locals: { widget: @widget }
    end

    private

      def report_options(options = {})
        options.reverse_merge!({
          company: controller.current_company,
          user: controller.current_user,
          end_date: Date.parse('05.02.2013')
        })
      end

      def interval_to_human(interval)
        if interval == 1
          'Сегодня'
        else
          "#{interval} #{Russian.p(interval, 'день', 'дня', 'дней')}"
        end
      end

      def number_to_human(amount, options = {})
        options.reverse_merge!(separator: ',', precision: 3, significant: false, units: :short_units)
        controller.view_context.number_to_human(amount, options)
      end

      def number_to_percentage(number)
        controller.view_context.number_to_percentage(number, separator: ',', precision: 2)
      end

      def percent_to_sign(percent)
        signs = ['&ndash;'.html_safe, {class: 'sign-up'}, {class: 'sign-down'}]
        signs[if percent === 0 then 0 elsif percent > 0 then 1 else 2 end]
      end

      def total_data(value, options = {})
        total_str = number_to_human(value, options[:number_to_human] || {})
        total = total_str.gsub(/[^\d,]+/, '')
        total_units = total_str.sub(total, '').strip
        {
          title: options[:title] || 'Всего',
          data: "#{total} <span>#{total_units}<span/>".html_safe,
          text: options[:text]
        }
      end

  end
end
