module UserPaymentsHelper
  def tariff_plan_ids
    tariff_plans = active_tariff_plans
    empty = [[t('user_payments.form.not_choise'), nil]]
    if tariff_plans
      empty + tariff_plans.collect { |tp| [tp.name, tp.id] }
    else
      empty
    end
  end

  def tariff_plans_data
    tariff_plans = active_tariff_plans
    if tariff_plans
      tariff_plans.collect { |tp| [tp.id, tp.currency, tp.price] }
    else
      nil
    end
  end

  def user_payments_statuses
    UserPayment::STATUSES.collect { |s| [ I18n.t(".user_payments.statuses.#{s}") , s ] }
  end

  private

    def active_tariff_plans
      TariffPlan.where(:active => true)
    end
end
