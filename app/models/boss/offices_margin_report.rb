# -*- encoding : utf-8 -*-
module Boss
  class OfficesMarginReport < OfficesIncomeReport
    include Margin
    include MarginGroup
  end
end