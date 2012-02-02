module ClaimsHelper
  def text_for_visa(claim)
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
    color = ''
    if claim.canceled?
      color = 'red_back' if claim.tourist_advance > 0
    else
      color = 'red_back' if claim.has_tourist_debt?
    end
    color
  end

  def color_for_operator_debt(claim)
    color = ''
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
    return 'all_done' if claim.new_record?
    !claim.visa_confirmation_flag ? 'all_done' : claim.visa
  end

  def color_for_visa_check(claim)
    if claim.visa_confirmation_flag?
      (%w[docs_sent visa_approved all_done].include?(claim.visa)) ? 'green_back' : 'red_back'
    end
  end

  def color_for_flight(claim)
    return 'empty' unless claim.depart_to

    if claim.depart_to > Time.now + 8.day
     'soon'
    elsif claim.depart_to > Time.now-1.day
      'hot'
    else
      'departed'
    end
  end
end
