class FillOwnerInCompany < ActiveRecord::Migration
  def up
    Company.select([:id]).find_each(:batch_size => 500) do |company|
      if company.id == 8
        boss = User.where(login: "boss", role: :boss).first
      else
        boss = User.where(company_id: company.id, role: :boss).first
      end
      company.update_column(:owner, boss.id) if boss != nil
    end
  end
end
