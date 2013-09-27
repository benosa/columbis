# -*- encoding : utf-8 -*-
class TasksController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :create_review

  before_filter :get_task, :only => [ :edit, :bug, :update, :edit, :emails ]

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

  def edit
  end

  def create
    # raise params.inspect
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.status = 'new' if params[:task][:status].blank?
    @task.body = nil if @task.body.empty?
    @task.executer_id = params[:task][:executer_id]

    respond_to do |format|
      format.html {
        if @task.save
          redirect_to ( current_user.role == 'admin' ? tasks_path : root_path )
          Mailer.task_info(@task).deliver
        else
          render :action => :new
        end
      }
      format.json {
        if @task.save
          render :json => { success: true, location: (current_user.role == 'admin' ? tasks_path : root_path)}
        else
          render :json => { success: false, content: render_to_string(partial: 'tasks/form', locals: { task: @task, as_popup: true }, formats: [ :html ]) }
        end
      }
    end

  end

  def create_review
    redirect_back unless current_user
    @task = Task.new(body: params[:review], status: 'new', image: params[:image])
    @task.user = current_user
    if @task.save
      redirect_back notice: t('tasks.messages.review_created')
    else
      redirect_to current_path, error: t('tasks.messages.review_failed')
    end
  end

  def update
    tparams = task_params
    is_updated = true
    if tparams[:status].present?
      status = tparams.delete(:status)
      comment = tparams.delete(:comment)
      is_updated = @task.fire_status_event(status, current_user, comment && {comment: comment}) # state_machine event firing
    end
    tparams[:comment] = comment
    is_updated = @task.update_attributes(tparams) if (is_updated and !tparams.empty?)
    respond_to do |format|
      format.html {
        if is_updated
          redirect_to tasks_path
        else
          render :edit
        end
      }
      format.js do
        if is_updated
          # Index isn't real time updated before thinking sphinx verison 3
          # options = set_filters(search_and_sort_options)
          # @task_in_search = Task.search_for_ids_with_options(options).include?(params[:id].to_i)
          @task.reload
          @task_in_search = task_in_search?(@task)
          render :update
        else
          render :text => ''
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

  def emails
    @emails = @task.emails
    if @emails.empty?
      flash[:notice] = "#[#{@task.id}] Писем не найдено"
      redirect_to tasks_path
    end
  end

  private

  def get_task
    @task = Task.find(params[:id])
  end

  def set_filters(options)
    filter = {}
    filter[:user_id] = params[:user_id] if params[:user_id].present?
    if params[:status].present? and params[:status] != 'all'
      filter[:status_crc32] = params[:status] == 'active' ? ['new'.to_crc32, 'work'.to_crc32] : params[:status].to_s.to_crc32
    end

    if params[:type].present? and params[:type] != 'all'
      filter[:bug] = params[:type] == 'bug'
    end

    options[:with] = (options[:with] || {}).merge!(filter) unless filter.empty?
    options
  end

  def task_params
    return {} unless params[:task]
    prms = params[:task].dup
    # case
    # when prms[:status] == 'work' then prms.merge!({ :executer => current_user, :start_date => Time.zone.now, :end_date => nil })
    # when %w(finish cancel).include?(prms[:status]) then prms.merge!({ :executer => current_user, :end_date => Time.zone.now })
    # end
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
