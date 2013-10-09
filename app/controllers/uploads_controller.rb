# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

  before_filter do
    unless is_admin? || current_company && current_company.id == params[:company_id].to_i
      raise CanCan::AccessDenied.new(I18n.t('unauthorized.default'), :read, Company)
    end
  end

  def show
    mime_type = Rack::Mime::MIME_TYPES['.' + params[:format]] if params[:format]
    file = company_file_path(params[:file], params[:format]) if params[:file]
    if file && File.exist?(file)
      options = { x_sendfile: true }
      options[:type] = mime_type if mime_type
      options[:disposition] = 'inline' if !params[:download] && inline_format?(params[:format])
      send_file file, options
    else
      render nothing: true
    end
  end

  protected

    def company_file_path(file, format = nil)
      company_dir = current_company ? current_company.id : 'default'
      Rails.root.join "uploads/#{company_dir}/#{file}#{'.' + format.to_s if format}"
    end

    def inline_format?(format)
      %w[html txt xml jpg jpeg gif png].include? format
    end
end