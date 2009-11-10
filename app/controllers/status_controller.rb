class StatusController < ApplicationController
  def show
    @builder_daemon_status = Ginst::Builder.status
    @plugins = Ginst::Plugin.plugins
    @environment = Rails.env
  end

end
