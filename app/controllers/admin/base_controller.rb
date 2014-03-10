module Admin
  class BaseController < ApplicationController

    before_filter { raise CanCan::AccessDenied unless is_admin? }

    def index
      if search_or_sort?
        options = search_and_sort_options(
          :filter => params[:filter],
          :defaults => { :order => :created_at, :sort_mode => :desc },
          :sql_order => false
        )
        @companies_collection = search_paginate(Company.search_and_sort(options))#Company.search_and_sort(options), options)
        @companies_info = Company.sort_by_search_results(@companies_collection) #.search params[:filter]
      else
        @companies_count = Company.count
        @users_count = User.count
        @claims_count = Claim.count
        @companies_collection = Company.order('created_at DESC').paginate(:page => params[:page], :per_page => per_page)
        @companies_info =  @companies_collection.all
      end

      if request.xhr?
        render :partial => 'admin/companies'
      else
        render 'admin/index'
      end
    end

    def instructions
      render 'admin/instructions'
    end

    def visitors
      if search_or_sort?
        options = search_and_sort_options(
          :filter => params[:filter],
          :defaults => { :order => :created_at, :sort_mode => :desc },
          :sql_order => false
        )
        @visitors_collection = search_paginate(Visitor.search_and_sort(options))#Company.search_and_sort(options), options)
        @visitors_info = Visitor.sort_by_search_results(@visitors_collection) #.search params[:filter]
      else
        @visitors_collection = Visitor.order('created_at DESC').paginate(:page => params[:page], :per_page => per_page)
        @visitors_info =  @visitors_collection.all
      end

      if request.xhr?
        render :partial => 'admin/visitors'
      else
        render 'admin/visitors'
      end
    end

    def companies_edit
      @company = Company.find(params[:company_id])
      render 'admin/companies_edit'
    end

    def companies_update
      @company = Company.find(params[:company_id])
      @company.update_attributes(params[:company])
      render 'admin/companies_edit'
    end

  end
end