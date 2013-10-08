# -*- encoding : utf-8 -*-
module PrintersHelper
  def mode_filter_options
    Printer::MODES.map{ |st| [ t("activerecord.attributes.printer.#{st}"), st ] }.unshift([I18n.t('.printers.list.all'), 'all'])
  end

  def create_printer_url(printer, mode)
    if printer.template.model[:template]
      "#{printer.template.url}?download=1"
    else
      name = mode
      if mode == 'memo' && printer.country
        name += '_' + printer.country.name
      end
      name += '.html'
      "/uploads/#{printer.company_id}/printer/#{name}?download=1&type=printer"
    end
  end
end