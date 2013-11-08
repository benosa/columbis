class AddInitialTariffPlans < ActiveRecord::Migration
  def up
    dafault_plans = [
      { name: 'Начинающий', price: 190, users_count: 4, place_size: '5', back_office: true, documents_flow: true,
        claims_base: true, crm_system: true },
      { name: 'Профи', price: 490, users_count: 10, place_size: '15', back_office: true, documents_flow: true,
        claims_base: true, crm_system: true, managers_reminder: true, sms_sending: true },
      { name: 'Эксперт', price: 790, users_count: 100, place_size: '35', back_office: true, documents_flow: true,
        claims_base: true, crm_system: true, managers_reminder: true, sms_sending: true, analytics: true, boss_desktop: true,
        default: true }
    ].each do |plan_attributes|
      TariffPlan.create plan_attributes
    end
  end

  def down
  end
end
