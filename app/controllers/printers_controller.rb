class PrintersController < ApplicationController
  load_and_authorize_resource

  def download
    @company = current_company
    if params[:template]
      @printer = @company.printers.find(params[:template])
      send_file @printer.template.path, :filename => @printer.template.file.identifier
    else
      render :'404'
    end
    #send_file @printer.template.path, :filename => @printer.template.file.identifier
  end

  def index
    @printers =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Printer))
        set_filter_to(options)
        search_paginate(Printer.search_and_sort(options).with_template_name, options)
      else
        Printer.accessible_by(current_ability).with_template_name.paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @printer = Printer.new
    @printer.country = Country.new
  end

  def create
    @printer.company = current_company
    if @printer.assign_reflections_and_save(params[:printer])
      redirect_to printers_path, :notice => t('printers.messages.successfully_created_printer')
    else
      @printer.country = Country.new
      render :action => :new
    end
  end

  def edit
    @printer = Printer.where(:id => params[:id]).first
  end

  def update
    if @printer.update_attributes(params[:printer])
      redirect_to printers_path, :notice => t('printers.messages.successfully_updated_printer')
    else
      render :action => :edit
    end
  end

  def destroy
    @printer = Printer.destroy(params[:id])
    index
  end

  private

    def set_filter_to(options)
      unless params[:mode_filter].nil? || params[:mode_filter] == 'all'
        options.merge! ( {:conditions => {:mode => t(".activerecord.attributes.printer.#{params[:mode_filter]}") }})
      end
    end
end