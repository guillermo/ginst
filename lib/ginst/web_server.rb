class Ginst::WebServer
  
  require('daemons')

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
    execute('status')
  end

  def self.run
    execute('run')
  end
  
  private

  def self.execute(command)
    script = Ginst.root+'/script/server'

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
    options = {
      :app_name => 'ginst',
      :dir_mode => :normal,
      :dir => File.expand_path((Ginst.data_dir || ENV['GINST_DIR'])+'/tmp'),
      :monitor => false,
      :mode => :exec,
      :log_output => true,
      :ARGV => [command]
    }  
  end
end

