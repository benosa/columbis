module ClaimsHelper
  def color_for_operator_debt(claim)
    return 'green_back' if claim.early_reservation?
    color = ''
    if claim.has_operator_debt?
      color = (claim.operator_advance > 0 ? 'orange_back' : 'red_back')
    end
    color
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

    day_of_week = claim.depart_to.to_a[6]
    day_of_week = 7 if day_of_week == 0

    monday = (claim.depart_to.to_date - (day_of_week - 1).days).to_time

    if monday > Time.now
     'soon'
    elsif (monday < Time.now and claim.depart_to > Time.now) or (claim.depart_to < Time.now)
      'hot'
    else
      'departed'
    end
  end
end
