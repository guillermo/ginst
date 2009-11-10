# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
 
class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  

  
  private
  
  # def load_models
  #   # Load models in development so STI not crash
  #   if Rails.env == 'development'
  #     # Dir.glob(RAILS_ROOT+'/app/models/*').each {|rm| Kernel.load rm if test(?f,rm)}
  #     # Dir.glob(Ginst.data_dir+'/plugins/*/app/models/*').each {|pm| Kernel.load pm if test(?f,pm)}
  #   end
  #   return true
  # end
  
  def load_project
    @project =  Project.find_by_slug(params[:project_id] || params[:id]) or raise ActiveRecord::RecordNotFound
    if @project.status == 'preparing' && controller_name != 'tasks'
      if @project.tasks.size == 1
        redirect_to project_task_path(@project,@project.tasks.first)
      else
        redirect_to project_tasks_path(@project)
      end
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
