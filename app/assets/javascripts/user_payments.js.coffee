$(document).ready ->

  # The page must init some params:
  # 1. tariffs:array - of all tariffs plans [[:id, :name, :price], ...]
  # 2. balance:integer - last period price
  # 3. t_balance - I18n.t('.balance')
  TariffPlanCheck =
    data: []
    amount: $('#user_payment_amount')
    tariff: $('#user_payment_tariff_id')
    period: $('#user_payment_period')
    currency: $('#user_payment_currency')
    balance: $('#if_balance')
    default_currency: "rur"

    init: ->
      this.data = tariffs if tariffs?
      this.period.val("1")
      this.tariff.on 'change', () -> TariffPlanCheck.period_change()
      this.period.on 'change', () -> TariffPlanCheck.period_change()
      this.period_change()

    period_change: ->
      id = parseInt this.tariff.val()
      period = parseInt this.period.val()
      if !isNaN(id) && !isNaN(period)
        period = period - 2 if period >= 12 # 2 month free
        N = this.data.length
        for _i in [0...N]
          t = this.data[_i]
          if t[0] == id
            amount = t[2] * period
            currency = t[1]
      else
        currency = this.default_currency
        amount = 0

      amount = amount - balance
      if amount < 0
        this.balance.text(t_balance + (amount*(-1)).toString())
        amount = 0
      else
        this.balance.text("")

      this.amount.val(amount)
      this.currency.ikSelect('select', currency)

  TariffPlanCheck.init() if $('#new_user_payment').length # if there is the payment form
