class AddDefaultTariffToAllCompany < ActiveRecord::Migration
  def up
    default = TariffPlan.default
    Company.update_all({
      tariff_id: default.id,
      tariff_end: Time.zone.now.to_date + CONFIG[:days_for_default_tariff].days
    })
  end
end
