

task :remove_data do
  puts 'Removing data'
  `rm -Rf #{DATA_DIR}`
end


desc 'Reset site
Recreate the database and remove data directory'
task :reset => ['db:drop', 'db:create', 'db:migrate', 'remove_data']


