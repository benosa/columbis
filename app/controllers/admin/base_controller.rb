module Admin
  class BaseController < ApplicationController

    before_filter { raise CanCan::AccessDenied unless is_admin? }

    def index
      if search_or_sort?
        options = search_and_sort_options(
          :defaults => { :order => :name, :sort_mode => :desc },
          :sql_order => false
        )
       # set_filters(options)
        @companies_collection = search_paginate(Company.search_and_sort(options))#Company.search_and_sort(options), options)
        @companies_info = Company.sort_by_search_results(@companies_collection) #.search params[:filter]
      else
        @companies_count = Company.count
        @users_count = User.count
        @claims_count = Claim.count
        @companies_collection = Company.paginate(:page => params[:page], :per_page => per_page)
        @companies_info =  @companies_collection.all
      end
      if request.xhr?
        render :partial => 'admin/companies'
      else
        render 'admin/index'
      end
    end

    #def set_filters(options)
    #  filter = {}
    #  filter[:user_id] = params[:user_id] if params[:user_id].present?
    #  if params[:status].present? and params[:status] != 'all'
      #  filter[:status_crc32] = params[:status] == 'active' ? ['new'.to_crc32, 'work'.to_crc32] : params[:status].to_s.to_crc32
     # end

    #  if params[:type].present? and params[:type] != 'all'
     #   filter[:bug] = params[:type] == 'bug'
     # end

     # options[:with] = (options[:with] || {}).merge!(filter) unless filter.empty?
     # options
    #end
  end
end