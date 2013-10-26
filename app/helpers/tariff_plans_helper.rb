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
end