# -*- encoding : utf-8 -*-
class ClaimPrintersController < ApplicationController
  def edit
    if %w[contract memo permit warranty act].include? params[:printer]
      @claim = Claim.find(params[:claim_id])
      @html = @claim.send(:"print_#{params[:printer]}")
    else
      redirect_to claims_url, :alert => "#{t('print_partial_not_found')} '#{params[:form]}'"
    end

    @head = "<style>dfgdfg</style>"
    @body = "<p>df33333gdfg</p>"
    render text: nil, layout: 'printer'
  end

end