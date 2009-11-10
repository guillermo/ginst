class TasksController < ApplicationController
  layout 'projects'
  before_filter :load_project
  
  
  def index
    scope = @project.tasks
    if params[:scope] && Task.valid_scopes.include?(params[:scope].to_sym)
      scope = scope.send(params[:scope].to_sym)
    end
    
    @tasks = scope.all(:order => 'ended_at DESC')
    
  end
  
  def update
    @task = @project.tasks.find(params[:id])
    
    if params[:kill]
      Rails.logger.info("Sending SIG#{params[:kill]} to process #{@task.pid}")
      @task.kill(params[:kill])
    end
    redirect_to :back
  end
  
  def show
    Task.first
    @task = @project.tasks.find(params[:id])
    
    respond_to do |wants|
      wants.html
      wants.js 
      wants.text { render :text => @task.output}
    end
  end
  
  
end
