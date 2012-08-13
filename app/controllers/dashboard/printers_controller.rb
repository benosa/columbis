class Dashboard::PrintersController < ApplicationController
  load_and_authorize_resource

  def download
    # @company = current_company unless @company
    # if params[:printer]
    #   @printer = @company.printers.find(params[:printer]).first
    #   send_file @printer.template.path, :filename => @printer.template.file.identifier
    # else
    #   render :404
    # end
    send_file @printer.template.path, :filename => @printer.template.file.identifier
  end  
end
