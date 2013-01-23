class TasksController < ApplicationController
  before_filter :get_task, :only => [ :to_user, :destroy, :cancel, :bug, :finish]
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
      @tasks_collection = Task.includes(:user).paginate(:page => params[:page], :per_page => per_page)
      @tasks = @tasks_collection.all
    end
    render :partial => 'tasks' if request.xhr?
    # respond_to do |format|
    #   format.js
    #   format.html
    # end 
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.status = 'new'
    @task.body = nil if @task.body.empty?

    if @task.save
      redirect_to ( current_user.role == 'admin' ? tasks_path : root_path )
    else
      render :action => :new
    end
  end

  def to_user
    @task.update_attributes :executer => current_user, :start_date => Time.now, :status => 'work', :end_date => nil
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.json { render :json => @task.status }
    end
  end

  def bug
    @task.update_attribute :bug, (params[:state] == '1')
    respond_to do |format|
      format.html do
        render :partial => 'task', :locals => { :task => @task } if request.xhr?
        redirect_to tasks_path unless request.xhr?
      end
      format.json { render :json => @task }
    end
  end

  def finish
    @task.update_attributes :status => 'finish', :end_date =>  Time.now
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.json { render :json => @task.status }
    end
  end

  def cancel
    @task.update_attribute :status, 'cancel'
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.json { render :json => @task.status }
    end
  end

  def destroy
    @task.update_attribute :status, 'delete'
    redirect_to tasks_path
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
    options[:with].merge!(filter) unless filter.empty?
  end
end
