class AddReferenceToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :sex, :string
    add_column :tourists, :reference, :string
  end
end
