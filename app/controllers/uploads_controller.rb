# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

  before_filter do
    if !current_company || current_company.id != params[:company_id].to_i
      raise CanCan::AccessDenied.new(I18n.t('unauthorized.default'), :read, Company)
    end
  end

  def get_file
    model = get_model(params[:model]) if params[:model]
    resource = model.find(params[:id]) if model && params[:id]
    mime_type = Rack::Mime::MIME_TYPES['.' + params[:format]] if params[:format]
    file = create_file_path(params, resource) if resource && mime_type && params[:filename]
    if file && File.exist?(file)
      if params[:download].to_boolean
        send_file file, :type => mime_type
      else
        send_file file, :type => mime_type, :disposition => 'inline'
      end
    else
      render nothing: true
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
      Rails.root.join "uploads/#{current_company.id}/#{file}#{'.' + format.to_s if format}"
    end

    def inline_format?(mime_type)
      %w[html txt xml jpg jpeg gif png].include? mime_type
    end

    def create_file_path(params, resource)
      relative_path = "/uploads/#{params[:model]}/#{params[:id]}/#{params[:filename]}.#{params[:format]}"
      file = get_public_file_path relative_path
      if file.nil? && can?(:get_file, resource)
        file = Rails.root.to_s + relative_path
      end
      file
    end

    def get_model(model_name)
      ActiveRecord::Base.subclasses.each do |model|
        return model if model.to_s.downcase == model_name.downcase
      end
      nil
    end

    def get_public_file_path(relative_path)
      full_path = Rails.root.to_s + "/public" + relative_path
      return ("/public" + relative_path) if File.exist?(full_path)
      nil
    end
end