class AddCompanyToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :company_id, :integer
  end
end
