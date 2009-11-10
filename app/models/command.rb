class Command < ActiveRecord::Base
  acts_as_list :scope => :task
  belongs_to :task

  validates_presence_of :command
  
  delegate :project, :to => :task
  
  class TaskCommandAlreadyRunning < Exception ; end
  
  def execute
    raise TaskCommandAlreadyRunning if reload[:started_at]
    
    update_attributes(:started_at => Time.current)
    
    run(command)
    return reload["exit_status"]
  rescue => e
    reload
    output = "#{output}\n#{e.to_s}\n #{e.backtrace.join("\n")}"
    return 100
  ensure
    ActiveRecord::Base.connection.reconnect!
    update_attribute(:ended_at, Time.current)
  end
  
  

  
  
end
