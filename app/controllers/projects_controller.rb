class ProjectsController < ApplicationController

  before_filter :load_project, :except => [:new, :index, :create]
  def new
    @project = Project.new
    render :layout => 'application'
  end
  
  def index
    redirect_to new_project_path and return if Project.count == 0 
    @projects = Project.all
    render :layout => 'application'
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to @project
    else
      render :action => 'new'
    end
  end
  
  def show
    # @this_week = @project.commits_between_dates(Time.current.beginning_of_week, Time.current.end_of_week)
    # @last_week = @project.commits_between_dates(1.week.ago.beginning_of_week, Time.current.beginning_of_week)
    redirect_to project_commits_path(@project)
  end
  
  def update
    if @project.update_attributes(params[:project])
      redirect_to :back
    else
      redirect_to project_edit_path(@project)
    end
  end
  
  def edit
  end
  
end
