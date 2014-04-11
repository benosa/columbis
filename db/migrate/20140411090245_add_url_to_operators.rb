class AddUrlToOperators < ActiveRecord::Migration
  def change
    add_column :operators, :url, :string
  end
end
