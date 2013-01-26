class TasksController < ApplicationController
  before_filter :get_task, :only => [ :to_user, :destroy, :cancel, :bug, :finish, :update]
  before_filter :get_tasks, :only => [ :index ]

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
      @tasks_collection = Task.active.includes(:user).paginate(:page => params[:page], :per_page => per_page)
      @tasks = @tasks_collection.all
    end
    render :partial => 'tasks' if request.xhr?
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.status = 'new' if params[:task][:status].blank?
    @task.body = nil if @task.body.empty?
    @task.executer_id = params[:task][:executer_id]

    if @task.save
      redirect_to ( current_user.role == 'admin' ? tasks_path : root_path )
    else
      render :action => :new
    end
  end

  def update
    is_updated = @task.update_attributes(task_params)
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.js do
        if is_updated
          # Index isn't real time updated before thinking sphinx verison 3
          # options = set_filters(search_and_sort_options)
          # @task_in_search = Task.search_for_ids_with_options(options).include?(params[:id].to_i)
          @task.reload
          @task_in_search = task_in_search?(@task)
          render(:update)
        else
          render(:text => '')
        end
      end
    end
  end

  def bug
    @task.update_attribute :bug, (params[:state] == '1')
    respond_to do |format|
      format.html do
        render :partial => 'task' if request.xhr?
        redirect_to tasks_path unless request.xhr?
      end
      format.json { render :json => @task }
    end
  end

  private

  def get_tasks
    @tasks = Task.by_status(['new', 'work']).order_created
    if params[:filter]
      @tasks = @tasks.filtered(params[:filter])
    end
  end

  def get_task
    @task = Task.find(params[:id])
  end

  def set_filters(options)
    filter = {}
    filter[:user_id] = params[:user_id] if params[:user_id].present?
    if params[:status].present? and params[:status] != 'all'
      filter[:status_crc32] = params[:status] == 'active' ? ['new'.to_crc32, 'work'.to_crc32] : params[:status].to_s.to_crc32
    end
    options[:with] = (options[:with] || {}).merge!(filter) unless filter.empty?
    options
  end

  def task_params
    return {} unless params[:task]
    prms = params[:task].dup
    case
    when prms[:status] == 'work' then prms.merge!({ :executer => current_user, :start_date => Time.now, :end_date => nil })
    when %w(finish cancel).include?(prms[:status]) then prms.merge!({ :executer => current_user, :end_date => Time.now })
    end
    prms.delete(:comment) if prms[:comment].blank?
    prms
  end

  def task_in_search?(task)
    in_search = true
    if params[:status].present? and params[:status] != 'all'
      in_search = false if params[:status] == 'active' and !%w(new work).include?(task.status)
      in_search = false if params[:status] != 'active' and task.status != params[:status]
    end
    in_search = false if !params[:bug].nil? and task.status != params[:bug]
    in_search
  end

end
