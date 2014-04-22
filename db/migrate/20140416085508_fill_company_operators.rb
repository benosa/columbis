class FillCompanyOperators < ActiveRecord::Migration
  def up
    Company.where(active: true).find_each do |company|
      if company.is_active?
        used_operators = CompanyOperator.where(company_id: company.id).pluck(:operator_id)
        used_operators << 0 if used_operators.empty?
        Operator.where("operators.id NOT IN (?)", used_operators).where(company_id: company.id, common: false).find_each do |operator|
          CompanyOperator.create(company_id: company.id, operator_id: operator.id)
          used_operators << operator.id
        end
        Operator.where("operators.id NOT IN (?)", used_operators).select('DISTINCT(operators.id)').where(common: true)
          .joins("JOIN claims ON claims.operator_id = operators.id AND claims.company_id = #{company.id}").find_each do |operator|
          CompanyOperator.create(company_id: company.id, operator_id: operator.id)
        end
      end
    end
  end

  def down
  end
end