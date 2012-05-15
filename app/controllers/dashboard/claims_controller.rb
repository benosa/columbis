class Dashboard::ClaimsController < ApplicationController
  def all
    authorize! :claims_all, current_user
    columns =  Claim.column_names
    render :json => current_company.claims.map{ |cl|
      cl.attributes
    }
  end
end
