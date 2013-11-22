class AddFieldsToOperator < ActiveRecord::Migration
  def up
    Operator.select([:id, :insurer_provision]).find_each(:batch_size => 500) do |operator|
      provision = operator.insurer_provision
      unless provision.blank?
        provision.gsub!(/\s/, '')
        skolko = provision.gsub(/[0-9]/, '')
        provision.gsub!(/[^0-9]/, '')
        if skolko.include?('млн')
          provision += "000000"
        elsif skolko.include?('тыс')
          provision += "000"
        end
      else
        provision = "0"
      end
      operator.update_column(:insurer_provision, provision)
    end

    execute 'ALTER TABLE operators ALTER COLUMN insurer_provision TYPE double precision USING (insurer_provision::double precision)'
    add_column :operators, :code_of_reason, :integer, :default => nil, :null => true
    add_column :operators, :full_name, :string, :default => '', :null => true
    add_column :operators, :banking_details, :string, :default => '', :null => true
    add_column :operators, :legal_address, :string, :default => '', :null => true
  end

  def down
    execute 'ALTER TABLE operators ALTER COLUMN insurer_provision TYPE character varying USING (insurer_provision::character varying)'
    remove_column :operators, :code_of_reason
    remove_column :operators, :full_name
    remove_column :operators, :banking_details
    remove_column :operators, :legal_address
  end
end
