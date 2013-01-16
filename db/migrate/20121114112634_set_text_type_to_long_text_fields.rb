class SetTextTypeToLongTextFields < ActiveRecord::Migration
  def up
    change_column :claims, :memo, :text
    change_column :claims, :docs_note, :text
    change_column :claims, :additional_services, :text
    change_column :claims, :calculation, :text
  end

  def down
    # These are destructive changes and they need to truncate strings before rollback.
    change_column :claims, :memo, :string
    change_column :claims, :docs_note, :string
    change_column :claims, :additional_services
    change_column :claims, :calculation, :string
  end
end
