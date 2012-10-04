# -*- encoding : utf-8 -*-
class Dashboard::ClaimsController < ApplicationController
  def all
    authorize! :claims_all, current_user
    claims =
      if params[:updated_at] and params[:updated_at] != 'null'
        current_company.claims.where('updated_at > ?', params[:updated_at])
      else
        current_company.claims
      end

    render :json => claims.map{ |cl| cl.attributes }
  end
end
