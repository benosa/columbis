# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController
  def logo_show
    company = Company.find(params[:id])
    if can?(:logo_show, Company) && company && company.logo?
      file = company.logo.try(:thumb)
      send_file file.url, :type => MIME::Types.type_for(file.url).first.content_type, :disposition => 'inline'
    else
      render nothing: true
    end
  end
end