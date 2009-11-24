class Task < ActiveRecord::Base
  
  DATABASE_UPDATE_INTERVAL = 2
  
  belongs_to :project
  
  validates_presence_of :project
  
  # attribute_choices :status, {'prepared' => 'Prepared', 'building' => 'Building', 
  #                             'fail' => 'Failure', 'success' => 'Epic Win'}
  
  named_scope :for_commit, lambda {|commit_sha1|
    {:conditions => {:commit_sha1 => commit_sha1},
     :order => 'created_at DESC'}
  }
  
  named_scope :prepared, {:conditions => {:status => 'prepared'}}
  named_scope :building, {:conditions => {:status => 'building'}}
  named_scope :fail,     {:conditions => {:status => 'fail'}}
  named_scope :success,  {:conditions => {:status => 'success'}}
  named_scope :finished, {:conditions => {:status => %w(success fail)}}
  named_scope :unfinished, {:conditions => {:status => %w(prepared building)}}
  
  named_scope :fetch_tasks, {:conditions => {:name => 'fetch.sh'}}
  
  delegate :logger, :to => :project
  
  def self.valid_scopes
    [:prepared,:building,:fail,:success,:finished]
  end
  
  def prepared?
    status == 'prepared'
  end
  
  def building?
    status == 'building'
  end
  
  def success?
    status == 'success'
  end
  
  def failure?
    status == 'fail'
  end
  
  def reset!
    update_attributes(
     :status => 'prepared',
     :started_at => nil,
     :ended_at => nil,
     :output => '',
     :exit_code => nil)
  end
  
  
  def kill(signal = 'INT')
    logger "Recived kill signal #{signal} for task #{id}"
    return nil unless pid
    pids = Sys::ProcTable.ps.find_all{|p| p.ppid == pid || p.pid == pid }.map{|p| p.pid}
    pids.each{ |pid| Process.kill(signal,pid) }
  end
  
  
  def parsed_output
    Ginst::ConsoleToHtml.convert(ERB::Util.html_escape output)
  end
  
  def build_duration
    return nil unless started_at
    if ended_at
      ended_at.to_i - started_at.to_i
    else
       Time.current.to_i - started_at.to_i
    end
  end
  
  def commit
    project.commit(commit_sha1)
  end
  
  class TaskAlreadyRunningException < Exception ; end
  class TaskAlreadyExecuteException < Exception ; end
  
  def execute
    raise TaskAlreadyExecuteException if reload[:ended_at]
    raise TaskAlreadyRunningException if reload[:started_at]
    status = 'fail'

    ObjectSpace.define_finalizer(self,lambda{
      update_attributes(:status => 'fail', :ended_at => Time.current, :exit_code => 66)
    })
    
    update_attributes(:started_at => Time.current, :status => 'building')
    logger "Executing task #{id} named #{name}"    
    run!
    run_callbacks!
    logger "Finished executing tasks"
    
    status = (exit_code == 0 ? 'success' : 'fail')    
  rescue => e
    puts e.inspect
    puts e.backtrace
    update_attributes(:output => "#{reload["output"]}\nThere was a error in ruby code:\n#{e.inspect}\n #{e.backtrace}")
    status = 'fail'
    exit_code
  ensure
    update_attributes(:ended_at => Time.current, :status => status, :exit_code => exit_code)
    ObjectSpace.undefine_finalizer(self)
  end
    
  class UnknowTaskFormat < Exception ; end
  def run!
    case
    when ruby_code?
      run_ruby!
    when shell_code?
      run_shell!
    else
      raise UnknowTaskFormat
    end
  end
  
  def run_ruby!
    output = ''
    output = eval(command,binding, name, 1)
  ensure
    update_attributes(:output => output, :exit_code => 0)
  end
  
  def ruby_code?
    name[/\.rb$/]
  end
  
  def shell_code?
    name[/\.sh$/]
  end
  
  
  def run_shell!
    buff = ''

    process_status = Open4.popen4(code) do |pid, stdin, stdout, stderr|
      update_attributes(:pid => pid)
      
      # Incremental update of the database
      inputs = [stdout,stderr]
      while ( !inputs.empty? ) do 
        select(inputs).first.each do |input|
          begin
            read = input.read_nonblock(99999999)
            logger read
            buff += read
            self.update_attribute(:output, buff) if output != buff && Time.now.to_i > updated_at.to_i + DATABASE_UPDATE_INTERVAL
          rescue EOFError
            logger "EOFError. removing #{stdout == input ? 'stdout' : 'stderr'} input"
            inputs.delete input
          end
        end
      end
      
    end
    logger "Finished popen"
    Process.wait
    logger "Really finished command"
    process_status.exitstatus    
  ensure
    self.update_attributes(:output => buff,:pid => nil, :exit_code => (process_status && process_status.exitstatus))
  end
  
  def run_callbacks!
    case exit_code
    when 0
      eval(on_success.to_s,binding, "Task(#{id}).on_success", 0)
    else
      eval(on_failure.to_s,binding, "Task(#{id}).on_success", 0)
    end
  end
  
end
