module TariffPlansHelper
  def tariff_plan_ids
    tariff_plans = active_tariff_plans
    tariff_plans.collect { |tp| [tp.name, tp.id] } if tariff_plans
  end

  def tariff_plans_data
    tariff_plans = active_tariff_plans
    tariff_plans.collect { |tp| [tp.id, tp.currency, tp.price] } if tariff_plans
  end

  def active_tariff_plans
    TariffPlan.where(:active => true).where("name <> 'По умолчанию'")
  end

  def company_tariff_balance(company)
    return 0 if company.user_payment.nil?

    tariff_start = company.user_payment.updated_at
    tariff_end = company.tariff_end
    paid = company.paid.to_i
    days = ((tariff_end - tariff_start)/86400).to_i
    day_amount = paid/days
    day_balance = ((tariff_end - Time.zone.now)/86400).to_i
    (day_amount*day_balance).to_f.round(2)
  end
end