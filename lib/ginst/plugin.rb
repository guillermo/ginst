class Ginst::Plugin
  def self.plugins
    ::Ginst::Plugin.subclasses.map{|a| eval(a)}
  end
  def self.paths
    plugins.inject({}){|memo,plugin|
      memo.merge(plugin.paths)
    }
  end
end
