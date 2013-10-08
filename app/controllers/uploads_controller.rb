# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

  before_filter do
    unless current_company || current_company.id == params[:company_id].to_i || (params[:company_id] == 'default' && is_admin?)
      raise CanCan::AccessDenied.new(I18n.t('unauthorized.default'), :read, Company)
    else
      @id = params[:company_id] == 'default' ? 'default' : current_company.id.to_s
    end
  end

  def show
    mime_type = Rack::Mime::MIME_TYPES['.' + params[:format]] if params[:format]
    file = company_file_path(params[:file], params[:format], params[:type]) if params[:file]
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

    def company_file_path(file, format = nil, type = nil)
      path = Rails.root.join "uploads/#{@id}/#{file}#{'.' + format.to_s if format}"
      if !File.exist?(path) && type == 'printer'
        filename = file.split('/').last
        path = Rails.root.join "app/views/printers/default_forms/#{I18n.locale}/#{filename}#{'.' + format.to_s if format}"
        if !File.exist?(path) && filename.first(4) == 'memo'
          path = Rails.root.join "app/views/printers/default_forms/#{I18n.locale}/memo.html"
        end
      end
      path
    end

    def inline_format?(mime_type)
      %w[html txt xml jpg jpeg gif png].include? mime_type
    end
end