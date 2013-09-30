class SetUsersSubdomainFromCompany < ActiveRecord::Migration
  def up
    Company.select([:id, :subdomain]).find_each(:batch_size => 500) do |company|
      boss = User.where(company_id: company.id, role: :boss).first
      boss.update_column(:subdomain, company.subdomain) if boss != nil
    end
  end
end
