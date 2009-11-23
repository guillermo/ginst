
class Ginst::Builder

  require('daemons')

  def self.start
    puts "builder daemon starting"
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
    ENV["RAILS_ENV"] = Rails.env rescue "production"
    
    script = Ginst.root+'/script/builder.rb'

    if command == 'status'
      capture_output do
        Daemons.run(script, generate_options_for_command(command))      
      end
    else
      pid = fork do
        $0 = 'builder'
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
      :app_name => 'builder',
      :dir_mode => :normal,
      :dir => Ginst.data_dir+'/tmp',
      :monitor => false,
      :mode => :exec,
      :log_output => true,
      :ARGV => [command]
    }  
  end


  def self.builder_script_path
    File.join(Ginst.root,%w(script builder))
  end



end

