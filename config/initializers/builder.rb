# Don't run builder neither change proc title for irb


if File.basename($0) == 'server'  
  puts 'Starting builder daemon'
  Rails.logger.info "Starting builder daemon"
    
  Ginst::Builder.start
  sleep 2
  Rails.logger.info Ginst::Builder.status
    
  at_exit {
    Rails.logger.info "Stoping Ginst Builder Daemon"
    puts Ginst::Builder.stop
  }
end