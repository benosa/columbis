class Dashboard::ClaimsController < ApplicationController
  def all
    authorize! :claims_all, current_user
    @claims = current_company.claims
  end
end
