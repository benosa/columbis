# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

  TariffPlanCheck =
    data: []
    amount: $('#user_payment_amount')
    tariff: $('#user_payment_tariff_id')
    period: $('#user_payment_period')
    currency: $('#user_payment_currency')
    default_currency: "rur"

    init: ->
      this.data = tariffs
      this.tariff.change () -> TariffPlanCheck.tariff_change()
      this.period.change () -> TariffPlanCheck.period_change()
      this.tariff_change()

    tariff_change: ->
      if this.tariff.val() == ""
        this.not_tariff_check()
      else
        this.tariff_check()

    not_tariff_check: ->
      this.amount.removeClass('disabled')
      this.amount.removeAttr('readonly')
      this.currency.ikSelect('enable')
      this.period.addClass('disabled')
      this.period.attr('readonly', 'true')
      this.period.val("")
      this.period_change()

    tariff_check: ->
      this.amount.addClass('disabled')
      this.amount.attr('readonly', 'true')
      this.currency.ikSelect('disable')
      this.period.removeClass('disabled')
      this.period.removeAttr('readonly')
      this.period.val("1")
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
