class AddRefusedNoteToTourists < ActiveRecord::Migration
  def change
  	add_column :tourists, :refused_note, :text
  end
end
