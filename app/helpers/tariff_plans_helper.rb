module TariffPlansHelper
  def tariff_plan_select_options
    tariff_plans = active_tariff_plans.order(:price)
    tariff_plans.collect { |tp| ["#{tp.name} (#{number_to_currency tp.price, precision: 0}/#{t('month').mb_chars.downcase})", tp.id] } if tariff_plans
  end

  def tariff_plans_data
    tariff_plans = active_tariff_plans
    tariff_plans.collect { |tp| [tp.id, tp.currency, tp.price, tp.price_half_year, tp.price_year, I18n.t(tp.currency)] } if tariff_plans
  end

  def active_tariff_plans
    TariffPlan.where(:active => true)
  end

  def company_tariff_balance(company)
    company.tariff_balance
  end
end