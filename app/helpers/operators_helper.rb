# -*- encoding : utf-8 -*-
module OperatorsHelper

  def common_operators?
    params[:availability] == 'common'
  end

  def source_filter_options
    I18n.t('operators.source_filter_options').invert.to_a
  end

  def from_reestr_class(operator)
    if operator.from_reestr?(current_company)
      " from_reestr"
    else
      ""
    end
  end

end
