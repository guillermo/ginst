
class Ginst::CLI
  
  require('daemons')
  
  def initialize(argv)    
    parse_args(argv)
  end
  
  def run
    
    if @install
      install
    elsif @daemon 
      if valid_dir?(@dir)
        daemon(@daemon,@dir)
      else
        error_and_exit("#{@dir} is not a valid dir.")
      end
    else
      show_help_and_exit
    end
  end
  
  def parse_args(argv)
    @action = nil
    @dir    = File.expand_path(ENV["GINST_DATA"] || Dir.pwd)
    @daemon = false
    @install = false
    while(current_arg = ARGV.shift) do 
      case current_arg
      when '-d'
        @dir = File.expand_path(ARGV.shift)
      when '-p'
        @port = ARGV.shift
      when '-a'
        Ginst::Configuration.adapter = ARGV.shift
      when '-d'
        Ginst::Configuration.database = ARGV.shift
      when '-u'
        Ginst::Configuration.username = ARGV.shift
      when '-p'
        Ginst::Configuration.password = ARGV.shift
      when '-h'
        Ginst::Configuration.host = ARGV.shift
      when 'start','stop','restart','status','run','development','console'
        @daemon = current_arg
      when 'install'
        @install = 'install'
      when '--help'
        show_help_and_exit
      else
        error_and_exit("Invalid argument: #{current_arg}")
        @action = 'help'
      end
    end
    
    ENV['GINST_DATA'] = @dir
    ENV['RAILS_ENV'] = 'production'
  end
  
  def launch_generator
    Ginst::Template.install_to(@dir)
  end
  
  def valid_dir?(dir)
    test(?d, dir) &&
    test(?f, dir+'/database.yml') &&
    test(?d, dir+'/log') &&
    test(?d, dir+'/projects') &&
    test(?d, dir+'/tmp')
  end
  
  def daemon(action,dir)
    Dir.chdir @dir    
    case action
    when 'development'
      ENV['RAILS_ENV'] = 'development'
      Ginst::WebServer.run
    when 'console'
      ENV['RAILS_ENV'] = 'development'
      Ginst::Console.start
    else
      Ginst::WebServer.send(action.to_sym)
    end
  end
  
  def install
    puts("#{green('Installing ginst')} in: #{@dir}\n")
    
    ask_yes_or_exit("#{@dir} is a valid ginst install. Overwrite?") if(valid_dir?(@dir))   
    launch_generator
    launch_migrations
    puts green("Ginst was installed")
    puts "run '#{File.basename($0)} start -d #{@dir}' to start ginst."
  end
  
  def launch_migrations
    puts "#{green("Creating the database.")}"
    require 'open3'
    Open3.popen3("cd #{Ginst.root}; rake db:drop db:create db:migrate") do |stdin,stdout,stderr|
      while(stdout.eof?) 
        puts stdout.gets
      end
      puts red(stderr.read)
    end
  end
  
  def error_and_exit(msg)
    puts msg
    show_help_and_exit
  end
  
  def show_help_and_exit
    puts("#{File.basename($0)} \n\n"+
         "usage: #{$0} [install|start|stop|status|restart|run|development|console] [-d dir] [command_options]\n\n"+
         "   install [-d dir]      # Install ginst. Default to current_dir\n"+
         "           [-a adapter]  # Default to mysql\n"+
         "           [-d database] # Default to ginst\n"+
         "           [-u username] # Default to root\n"+
         "           [-p password] # Default to blank\n"+
         "           [-h host]     # Default to host\n\n"+
         "   start   [-d dir]      # Start ginst\n"+
         "   stop    [-d dir]      # Stop ginst\n"+
         "   status  [-d dir]      # Status of ginst\n"+
         "   restart [-d dir]      # Restart ginst\n\n"+
         "   run     [-d dir]      # Run ginst in foreground\n"+
         "   development [-d dir]  # Start ginst in developer mode\n"+
         "   console [-d dir]      # Start ginst console\n\n"+
         "   --help                # Show this help\n\n")
    exit(-1)
  end
  
  def ask_yes_or_exit(question)
    print question+" #{red('[Y/n]')}:"
    if $stdin.gets.strip.downcase == 'n'
      exit(-2)
    end
  end
  
  def red(msg)
    "\e[1;31m#{msg}\e[0m"
  end
  
  def green(msg)
    "\e[1;32m#{msg}\e[0m"
  end
end