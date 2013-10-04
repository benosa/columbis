module Admin
  class BaseController < ApplicationController

    before_filter { raise CanCan::AccessDenied unless is_admin? }

    def index
      if search_or_sort?
        options = search_and_sort_options(
          :defaults => { :order => :id, :sort_mode => :desc },
          :sql_order => false
        )
        set_filters(options)
        @tasks_collection = search_paginate(Task.search_and_sort(options).includes(:user), options)
        @tasks = Task.sort_by_search_results(@tasks_collection)
      else
         @companies_collection = Company.paginate(:page => params[:page], :per_page => per_page)
         @companies_info =  @companies_collection.all
      end
      #render :partial => 'tasks' if request.xhr?
      render 'admin/index'
    end
  end
end