class FillCountFieldsInCompany < ActiveRecord::Migration
  def up
    Company.select([:id]).find_each(:batch_size => 500) do |company|
      Company.update_counters(company.id,
        :offices_count => Office.where(company_id: company.id).count,
        :users_count => User.where(company_id: company.id).count,
        :claims_count => Claim.where(company_id: company.id).count,
        :tourists_count => Tourist.where(company_id: company.id).count,
        :tasks_count => Task.where(company_id: company.id).count
      )
    end
  end
end
