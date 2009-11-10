class CommitsController < ApplicationController
  layout 'projects'
  before_filter :load_project
  
  def index
    if params[:secret]
      create
    else
      params[:branch] ||= 'master'
      @commits = @project.commits(params[:branch],10,params[:page].to_i || 1)
    end
  end

  def show
    @commit = @project.commits
  end
  
  def update
    @project.create_task_for_build_commit(params[:id])
      
    respond_to do |wants|
      wants.html do
        redirect_to :back
      end
    end
  end
  
  def create
    if params[:secret] == @project.preferences.secret
      task = @project.create_fetch_task
      redirect_to project_task_path(@project,task)
    else
      raise ActionController::MethodNotAllowed
    end
  end
  

end
