# -*- encoding : utf-8 -*-
module OperatorsHelper

  def common_operators?
    params[:availability] == 'common'
  end

  def source_filter_options
    I18n.t('operators.source_filter_options').invert.to_a
  end

end
