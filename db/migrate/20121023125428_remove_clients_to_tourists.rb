class RemoveClientsToTourists < ActiveRecord::Migration
  def up
    add_column :tourists, :potential, :boolean, :null => false, :default => false
    add_index :tourists, :potential

    # Move clients data to tourists table
    Tourist.reset_column_information
    columns = Tourist.columns.map(&:name)
    columns.delete('id');
    Client.find_each do |client|
      attributes = Hash[client.attributes.select{ |a, v| columns.include?(a) }]
      attributes.merge!({
        :company_id => client.company_id,
        :potential => true
      })
      tourist = Tourist.new()
      tourist.assign_attributes(attributes, :without_protection => true)
      tourist.build_address(:region => client.address, :joint_address => client.address)
      tourist.save(:validate => false)
    end

    # Move clients data to tourists table
    # columns = [:company_id, :first_name, :last_name, :middle_name, :passport_series, :passport_number, :phone_number, :passport_valid_until, :date_of_birth, :created_at, :updated_at].join(' ')
    # pgres = execute("INSERT INTO tourists (#{columns}, potential) SELECT #{columns}, true FROM clients RETURNING id;")
    # ids = pgres.column_values(0)
    # execute("INSERT INTO addresses (addressable_type, addressable_id, region, joint_address) SELECT 'Tourist', id, address, address FROM tourists W;")

    drop_table :clients
  end

  def down
    create_table :clients do |t|
      t.integer :company_id
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.integer :passport_series
      t.integer :passport_number
      t.string :phone_number
      t.string :address
      t.date :passport_valid_until
      t.date :date_of_birth

      t.timestamps
    end

    # Move potential tourists to clients table, require Client model
    Client.reset_column_information
    columns = Client.columns.map(&:name)
    columns.delete('id');
    Tourist.where(:potential => true).find_each do |tourist|
      attributes = Hash[tourist.attributes.select{ |a, v| columns.include?(a) }]
      attributes.merge!({
        :company_id => tourist.company_id,
        :address => tourist.address.try(:joint_address)
      })
      client = Client.new()
      client.assign_attributes(attributes, :without_protection => true)
      client.save(:validate => false)
      tourist.destroy # must destroy record in addresses table
    end

    remove_index :tourists, :potential
    remove_column :tourists, :potential
  end
end
