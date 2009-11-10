#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

loop do
  Project.all.each do |project|
    begin 
      ENV.delete 'RAILS_ENV'
      project.run_tasks! unless project.building?
    rescue ProjectLockedException
      puts "#{project.name} is building"
    end
  end
  
  sleep 10
end