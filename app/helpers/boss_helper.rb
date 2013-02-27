# -*- encoding : utf-8 -*-
module BossHelper

  def row_count_options
    [[t('report.all_rows'), 0], 5, 10, 20]
  end

  def period_options
    %w(day week month year).map{ |p| [t("report.period_options.#{p}"), p] }
  end

end