# -*- encoding : utf-8 -*-
module PrintersHelper
  def mode_filter_options
    Printer::MODES.map{ |st| [ t("activerecord.attributes.printer.#{st}"), st ] } << [I18n.t('.printers.list.all'), 'all']
  end
end