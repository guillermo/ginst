class SimpleBuildsController < PluginController

  def show
    
  end
  
  def index
    @commits = @project.commits(params[:branch],10,params[:page].to_i || 1)
  end
  
  def create
    conf = SimpleBuildConf.new(@project.slug)
    conf.build = params[:build]
    conf.save
    redirect_to :back
  end
end