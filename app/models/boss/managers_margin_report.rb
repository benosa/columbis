# -*- encoding : utf-8 -*-
module Boss
  class ManagersMarginReport < ManagersIncomeReport
    include Margin
    include MarginGroup
  end
end