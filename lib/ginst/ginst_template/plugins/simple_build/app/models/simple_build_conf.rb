class SimpleBuildConf
  @@conf = {}
  
  def initialize(project)
    @project = project
    set_default_conf unless @@conf[project]
  end
  
  def build
    @@conf[@project]['build']
  end
  
  def save
    self.class.write_conf
  end
  
  def build=(new_build)
    @@conf[@project]['build'] = new_build
  end
  
  def self.read_conf
    @@conf = YAML.load(File.read(file))
  end
  
  def self.write_conf
    File.open(file,'w'){|f|
      f.write YAML.dump(@@conf)
    }
  end
  
  private
  def self.file
    File.dirname(__FILE__)+'/../../config/build.yml'
  end
  
  def set_default_conf
    @@conf[@project] = @@conf['default'].dup
  end
end

SimpleBuildConf.read_conf