#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

loop do
  
  Project.all.each do |project|
    begin 
      ENV.delete 'RAILS_ENV'
      project.run_tasks! unless project.building?
    rescue Project::ProjectLockedException
      puts "#{project.name} is building"
    rescue => e
      puts e.inspect
      puts e.backtrace*"\n"
      
    end
  end
  
  sleep 10
end