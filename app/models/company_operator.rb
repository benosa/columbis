# -*- encoding : utf-8 -*-
class CompanyOperator < ActiveRecord::Base
  attr_accessible :company_id, :operator_id
  belongs_to :company
  belongs_to :operator
end
