class PrintersController < ApplicationController
  load_and_authorize_resource

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

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
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