class AddFieldsToTourists < ActiveRecord::Migration
  def change
  	add_column :tourists, :assistant_id, :integer
  	add_column :tourists, :office_id, :integer
  end
end
