class TasksController < ApplicationController
  before_filter :get_task, :only => [ :to_user, :destroy, :cancel, :bug ]
  before_filter :get_tasks, :only => [ :index ]

  def index
    respond_to do |format|
      format.js
      format.html
    end 
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.status = 'new'
    @task.body = nil if @task.body.empty?
    @task.save ? redirect_to(root_path) : render(:action => :new)
  end

  def to_user
    @task.executer = current_user
    @task.start_date = Time.now
    @task.status = 'work'
    @task.save
    redirect_to tasks_path
  end

  def bug
    @task.update_attribute :bug, (params[:state] == '1')
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.json { render :json => @task.bug }
    end
  end

  def cancel
    @task.update_attribute :status, 'cancel'
    redirect_to tasks_path
  end

  def destroy
    @task.update_attribute :status, 'delete'
    redirect_to tasks_path
  end

  private

  def get_tasks
    @tasks = Task.all
  end

  def get_task
    @task = Task.find(params[:id])
  end
end
