class FillCompanyOperators < ActiveRecord::Migration
  def up
    Company.where(active: true).all.each do |company|
      if company.is_active?
        Operator.where(company_id: company.id, common: false).all.each do |operator|
          CompanyOperator.create(company_id: company.id, operator_id: operator.id)
        end
        Operator.select('DISTINCT(operators.id)').where(common: true)
          .joins("JOIN claims ON claims.operator_id = operators.id AND claims.company_id = #{company.id}").all.each do |operator|
          CompanyOperator.create(company_id: company.id, operator_id: operator.id)
        end
      end
    end
  end

  def down
  end
end