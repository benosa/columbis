# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

  # The page must init some params:
  # 1. tariffs:array - of all tariffs plans [[:id, :name, :price], ...]
  # 2. now_tariff:string - id of now tariff plan
  # 3. t_new_tariff:string - I18n.t('new_tariff')
  # 4. t_old_tariff:string - I18n.t('old_tariff')
  TariffPlanCheck =
    data: []
    amount: $('#user_payment_amount')
    tariff: $('#user_payment_tariff_id')
    tariff_label: $('#tariff_label')
    period: $('#user_payment_period')
    currency: $('#user_payment_currency')
    default_currency: "rur"

    init: ->
      this.data = tariffs
      this.period.val("1")
      this.tariff.bind 'change', () -> TariffPlanCheck.tariff_change()
      this.period.bind 'input', () -> TariffPlanCheck.period_change()
      this.tariff_change()

    tariff_change: ->
      id = this.tariff.val()
      if id == now_tariff
        this.tariff_label.text(t_old_tariff)
      else
        this.tariff_label.text(t_new_tariff)
      this.period_change()

    period_change: ->
      id = this.tariff.val()
      period = this.period.val()
      if id != "" && period != ""
        i = parseInt(id)
        N = this.data.length
        for _i in [0...N]
          t = this.data[_i]
          if t[0] == i
            amount = t[2]*parseInt(period)
            currency = t[1]
      else
        currency = this.default_currency
        amount = ""
      this.amount.val(amount)
      this.currency.ikSelect('select', currency)

  TariffPlanCheck.init()
