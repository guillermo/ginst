
module Ginst::Template
  
  require('templater')
  
  extend Templater::Manifold
  
  class GinstData < Templater::Generator
    desc 'Ginst data directory generator'
  
    def self.source_root
      File.join(File.dirname(__FILE__), 'ginst_template')
    end
  
    template :database, 'database.yml'

    empty_directory :log, "log"
    empty_directory :projects, "projects"
    empty_directory :tmp, "tmp"
    empty_directory :plugins, "plugins"
    
  end  
  
  class PluginData < Templater::Generator
    def self.source_root
      File.join(File.dirname(__FILE__), 'ginst_template/plugins')
    end
    glob!
  end
  
  add :base, GinstData
  add :plugins, PluginData
  
  def self.install_to(dir)
    run_cli(dir, 'base', '0.0', ['base'])
    run_cli(dir+'/plugins', 'plugins', '0.0', ['plugins'])
  end
end


