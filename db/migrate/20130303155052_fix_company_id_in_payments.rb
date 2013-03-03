class FixCompanyIdInPayments < ActiveRecord::Migration
  def up
    # Fix incorrent payer_id and recipient_id in payments
    ActiveRecord::Base.connection.execute "UPDATE payments SET payer_id = company_id WHERE id in (SELECT id FROM payments WHERE payer_type = 'Company' AND payer_id != company_id);"
    ActiveRecord::Base.connection.execute "UPDATE payments SET recipient_id = company_id WHERE id in (SELECT id FROM payments WHERE recipient_type = 'Company' AND recipient_id != company_id);"
  end
end
