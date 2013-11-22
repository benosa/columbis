class AddReferenceToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :sex, :string, :default => 'not_selected'
  end
end