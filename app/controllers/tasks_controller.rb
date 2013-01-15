class TasksController < ApplicationController
	def index
		@tasks = Task.all
	end

	def new
		@task = Task.new
	end

	def create
		@task = Task.new(params[:task])
		@task.user = current_user
		@task.status = 'new'
		if @task.save
			redirect_to root_path
		end
	end

	def to_user
		@task = Task.find(params[:id])
		@task.executer = current_user.id
		@task.start_date = Time.now
		@task.save
		redirect_to tasks_path
	end
end
