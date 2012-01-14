module ClaimsHelper
  def color_for_operator_debt(claim)
    return 'green_back' if claim.early_reservation?
    color = ''
    if claim.has_operator_debt?
      color = (claim.operator_advance > 0 ? 'orange_back' : 'red_back')
    end
    color
  end
end
