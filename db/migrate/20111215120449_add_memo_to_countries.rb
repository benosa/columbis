class AddMemoToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :memo, :string
  end
end
