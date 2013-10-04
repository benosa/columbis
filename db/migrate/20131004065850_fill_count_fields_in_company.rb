class FillCountFieldsInCompany < ActiveRecord::Migration
  def up
    Company.select([:id]).find_each(:batch_size => 500) do |company|
      company.update_column(:offices_count, Office.where(company_id: company.id).count)
      company.update_column(:users_count, User.where(company_id: company.id).count)
      company.update_column(:claims_count, Claim.where(company_id: company.id).count)
      company.update_column(:tourists_count, Tourist.where(company_id: company.id).count)
      tasks_count = 0
      User.select([:id]).where(company_id: company.id).find_each(:batch_size => 500) do |user|
        tasks_count += Task.where(user_id: user.id).count
      end
      company.update_column(:tasks_count, tasks_count)
    end
  end
end
