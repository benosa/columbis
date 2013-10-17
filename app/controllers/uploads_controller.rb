# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

  before_filter do
    unless is_admin? || current_company && current_company.id == params[:company_id].to_i
      raise CanCan::AccessDenied.new(I18n.t('unauthorized.default'), :read, Company)
    end
  end

  def show
    file = company_file_path(params[:company_id], params[:file]) if params[:file]
    if file && File.exist?(file)
      ext = File.extname(file).downcase.tr('.','')
      mime_type = Mime::Type.lookup_by_extension ext
      options = {}
      options[:type] = mime_type if mime_type
      options[:disposition] = 'inline' if !params[:download] && inline_format?(ext)
      send_file file, options
    else
      render nothing: true
    end
  end

  protected

    def company_file_path(company_dir, file)
      Rails.root.join "uploads/#{company_dir}/#{file}"
    end

    def inline_format?(format)
      %w[html txt xml jpg jpeg gif png].include? format
    end
end