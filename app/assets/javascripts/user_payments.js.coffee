$(document).ready ->

  # The page must init some params:
  # 1. tariffs:array - of all tariffs plans [[:id, :name, :price], ...]
  # 2. balance:integer - last period price
  # 3. t_balance - I18n.t('.balance')

  TariffPlanCheck =
    data: []
    periods: {}
    amount: $('#user_payment_amount')
    tariff: $('#user_payment_tariff_id')
    period: $('#user_payment_period')
    currency: $('#user_payment_currency')
    balance: $('#if_balance')
    default_currency: "rur"

    init: ->
      this.data = tariffs if tariffs?
      this.periods = periods if periods?
      this.tariff.on 'change', () -> TariffPlanCheck.period_change()
      this.period.on 'change', () -> TariffPlanCheck.period_change()
      this.period_change()

    period_change: ->
      id = parseInt this.tariff.val()
      period = parseInt this.period.val()
      if !isNaN(id) && !isNaN(period)
        $('#user_payment_period').ikSelect("remove_options", ['1', '3', '6', '12'])
        #period = period - 2 if period >= 12 # 2 month free
        N = this.data.length
        for _i in [0...N]
          t = this.data[_i]
          if t[0] == id
            $('#user_payment_period').ikSelect("add_options", { 1: this.periods[1] + ' (' + t[2] + ' ' + t[5] + ')'})
            $('#user_payment_period').ikSelect("add_options", { 3: this.periods[3] + ' (' + 3 * t[2] + ' ' + t[5] + ')'})
            $('#user_payment_period').ikSelect("add_options", { 6: this.periods[6] + ' (' + t[3] + ' ' + t[5] + ')'})
            $('#user_payment_period').ikSelect("add_options", { 12: this.periods[12]  + ' (' + t[4] + ' ' + t[5] + ')'})
            $('#user_payment_period').ikSelect("select", period)
            if period < 6
              amount = t[2] * period
            else if period == 6
              amount = t[3]
            else
              amount = t[4]

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
