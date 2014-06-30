class AddClientStatToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :client_stat, :string
  end
end
