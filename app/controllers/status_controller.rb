class StatusController < ApplicationController
  def show
    @builder_daemon_status = Ginst::Builder.status
    @plugins = Ginst::Plugin.plugins
    @environment = Rails.env
  end


  def update
    case params['what']
    when 'restart_builder'
      Ginst::Builder.restart
    else
    end
    
    redirect_to :back
  end
end
