# -*- encoding : utf-8 -*-
module ClaimsHelper
  def truncate(text, options = {})
    options.reverse_merge!(:omission => '')
    super
  end

  def operator_price(claim)
    claim.operator_price.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def operator_advance(claim)
    claim.operator_advance.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def operator_debt(claim)
    claim.operator_debt.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
  end

  def approved_advance(claim, who)
    case who
    when :tourist
      claim.approved_tourist_advance.to_money + CurrencyCourse.currency_symbol(CurrencyCourse::PRIMARY_CURRENCY)
    when :operator
      claim.approved_operator_advance.to_money
    when :operator_prim
      claim.approved_operator_advance_prim.to_money + CurrencyCourse.currency_symbol(claim.operator_price_currency)
    end
  end

  def tourists_list(claim)
    ([claim.applicant.full_name] + claim.dependents.map{ |o| o.full_name }).join(', ')
  end

  def text_for_visa(claim)
    return '' if claim.canceled?

    if claim.visa_confirmation_flag
      if claim.visa == 'docs_sent'
        t('claims.index.sent')
      else
        t('claims.index.visa')
      end
    else
      t('nope')
    end
  end

  def check_date_status(claim)
    return '' if claim.canceled?
    return 'hot' unless claim.check_date

    if claim.closed?
      'departed'
    elsif (claim.check_date - 1.day) <= Time.now.to_date
      'hot'
    else
      'soon'
    end
  end

  def color_for_tourist_advance(claim)
    return '' if claim.canceled?

    color = 'blue_back'
    if claim.canceled?
      color = 'red_back' if claim.tourist_advance > 0
    else
      color = 'red_back' if claim.has_tourist_debt?
    end
    color
  end

  def color_for_operator_debt(claim)
    return '' if claim.canceled?

    color = 'blue_back'
    if claim.has_operator_debt?
      return 'green_back' if claim.early_reservation?
      color = (claim.operator_advance > 0 ? 'orange_back' : 'red_back')
    end
    color
  end

  def color_for_operator_advance(claim)
    'red_back' if claim.canceled? and claim.operator_advance > 0
  end


  def color_for_visa(claim)
    return '' if claim.canceled?

    return 'all_done' if claim.new_record?
    !claim.visa_confirmation_flag ? 'all_done' : claim.visa
  end

  def color_for_visa_check(claim)
    return '' if claim.canceled?

    if claim.visa_confirmation_flag?
      (%w[docs_sent visa_approved all_done].include?(claim.visa)) ? 'green_back' : 'red_back'
    end
  end

  def color_for_flight(claim)
    return '' unless claim.depart_to
    return '' if claim.canceled?

    if claim.depart_to > Time.now + 8.day
     'soon'
    elsif claim.depart_to > Time.now-1.day
      'hot'
    else
      'departed'
    end
  end
end
