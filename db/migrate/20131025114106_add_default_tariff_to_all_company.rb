class AddDefaultTariffToAllCompany < ActiveRecord::Migration
  def up
    default = TariffPlan.default

    Company.select([:id, :tariff_id, :user_payment_id, :tariff_end])
        .find_each(:batch_size => 500) do |company|
      company.update_column(:tariff_id, default.id)
      company.update_column(:tariff_end, (Time.zone.now.to_date +
        CONFIG[:days_for_default_tariff].days))
    end
  end
end
