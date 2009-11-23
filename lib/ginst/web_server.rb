class Ginst::WebServer
  
  require('daemons')
  require('yaml')

  def self.development
    execute('start')
  end
  
  def self.start
    execute('start')
  end

  def self.restart
    execute('restart')
  end

  def self.stop
    execute('stop')
  end

  def self.status
    puts execute('status')
  end

  def self.run
    execute('run')
  end
  
  private

  def self.execute(command)
    script = 
    if ['start','restart','run'].include? command
      config = read_config
      script = [Ginst.root+'/script/server', '-b',config["address"],'-p', config["port"].to_s].join(' ')
    else
      script = Ginst.root+'/script/server'
    end
    
      
    if command == 'status'
      capture_output do
        Daemons.run(script, generate_options_for_command(command))      
      end
    else
      pid = fork do
        Daemons.run(script, generate_options_for_command(command))
        exit(0)
      end
      Process.waitpid2(pid)
      status
    end
  end

  def self.capture_output
    $stdout, $stderr = StringIO.new, StringIO.new
    yield
    $stdout.string + $stderr.string
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end

  def self.generate_options_for_command(command)
    argv = [command]
    
    {
      :app_name => 'ginst',
      :dir_mode => :normal,
      :dir => File.expand_path((Ginst.data_dir || ENV['GINST_DIR'])+'/tmp'),
      :monitor => false,
      :mode => :exec,
      :log_output => true,
      :ARGV => argv
    }     
  end
  
  def self.read_config
    options = {"address" => '0.0.0.0', "port" => 3000}
    config_file = Ginst.data_dir+"/webserver.yml"
    config_options = YAML.load(File.read(config_file)) rescue {}
    options.merge(config_options)
  end
  
end

