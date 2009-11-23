# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'ostruct'
require 'ginst'
require 'sys/proctable'


Rails::Initializer.run do |config|
  
  config.gem 'ryanb-acts-as-list', :lib => 'acts_as_list', :source => 'http://gems.github.com'
  config.gem 'open4'
  config.gem 'daemons'
  config.gem 'templater'

  config.database_configuration_file = Ginst.data_dir+'/database.yml' if Ginst.data_dir
  config.log_path = Ginst.data_dir+'/log/ginst.rails.log' if Ginst.data_dir
  config.plugin_paths = [RAILS_ROOT+'/vendor/plugins', Ginst.data_dir+'/plugins'] if Ginst.data_dir

  config.reload_plugins = true if RAILS_ENV == 'development'

  config.plugins = [ :authlogic, :grit, :slugify, :all ]

  config.load_paths += [Ginst.data_dir+'/lib'] if Ginst.data_dir

  config.time_zone = 'UTC'


  config.action_controller.session = {
    :session_key => '_ginst.rails_session',
    :secret      => '6949e9f728e4b8bad76dea62b40486f2b61e227e5b5c5071e2f1e6e0e17934690e6533a24405693bf23d049b2f673cd10d8fbed9c6abc7fe3bd742da039be8b6'
  }

  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
end


