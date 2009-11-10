class PluginController < ApplicationController

  before_filter :load_project
  layout 'projects'
  
end
