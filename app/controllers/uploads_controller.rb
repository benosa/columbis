# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

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

  protected

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