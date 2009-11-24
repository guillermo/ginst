

class Ginst::Logger 
  
  def initialize(file)
    @filename = file
    @file = File.open(file,'a')
    @file.sync = true
    
    ObjectSpace.define_finalizer(self) do
      puts self.class.to_s
      puts 'Cerrando log file'
      @file.close
    end
  end
  
  def log(msg,acaller = nil)
    acaller ||= caller
    msg = format_msg(msg,acaller)
    @file.write(msg)
    msg
  end
  
    
  def format_msg(msg, caller)
    call = File.basename(caller.first).split(":")[0..1].join(":")
    "[%s %s] %s\n" % [Time.now.to_s, call, msg]
  end
end
  
  