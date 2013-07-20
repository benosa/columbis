# -*- encoding : utf-8 -*-
module BossHelper

  def row_count_options
    [[t('report.all_rows'), 0], 5, 10, 20]
  end

  def period_options
    %w(day week month year).map{ |p| [t("report.period_options.#{p}"), p] }
  end

  def margin_options
    %w(profit profit_acc profit_in_percent profit_in_percent_acc).map{ |p| [t("report.margin_options.#{p}"), p] }
  end

end