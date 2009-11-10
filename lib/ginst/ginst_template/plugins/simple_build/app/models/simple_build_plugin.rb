
class ::SimpleBuildPlugin < ::Ginst::Plugin
  @@name = 'Simple Build'
  @@paths = {:'Builds' => lambda{project_simple_builds_path(project)}}
  @@config_partial = 'simple_builds/config'
  cattr_reader :name, :paths, :config_partial
  
  
  def self.on_commit(project,branch)
    SimpleBuild.create_for_branch(project,branch)
  end
end