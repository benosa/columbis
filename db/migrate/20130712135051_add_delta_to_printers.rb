class AddDeltaToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :delta, :boolean, :default => true, :null => false
  end
end
