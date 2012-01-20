class ChangeDocsReadyInClaims < ActiveRecord::Migration
  def up
    add_column :claims, :documents_status, :string, :default => 'not_ready'
    remove_column :claims, :docs_ready
  end

  def down
    add_column :claims, :docs_ready, :boolean, :default => false
    remove_column :claims, :documents_status
  end
end
