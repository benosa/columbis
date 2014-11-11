class AddNewTariffPlans < ActiveRecord::Migration
  def up
    TariffPlan.where(name: 'Профи').first.update_column(:name, 'Профи(старый)')
    TariffPlan.update_all(:active => false, :default => false)
    dafault_plans = [
      { name: 'Бесплатный', price: 0, users_count: 1, claims_count: 10, offices_count: 1, place_size: '5',
        back_office: true, documents_flow: true, claims_base: true, crm_system: true, managers_reminder: true,
        sms_sending: true, analytics: true, boss_desktop: true, default: true },
      { name: 'Эконом', price: 1000, price_half_year: 5400, price_year: 9600, offices_count: 1, users_count: 5,
        place_size: '15', back_office: true, documents_flow: true, claims_base: true, crm_system: true,
        managers_reminder: true, sms_sending: true, analytics: true,
        boss_desktop: true },
      { name: 'Профи', price: 2500, price_half_year: 13500, price_year: 24000, users_count: 999, place_size: '35',
        back_office: true, documents_flow: true, claims_base: true, crm_system: true, managers_reminder: true,
        sms_sending: true, analytics: true, boss_desktop: true }
    ].each do |plan_attributes|
      TariffPlan.create plan_attributes
    end
  end

  def down
  end
end
