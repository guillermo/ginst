class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.string :type
      
      t.references :project
      t.string :commit_sha1
      
      t.text :code    
      t.integer :priority, :default => 20
      t.text :on_success
      t.text :on_failure
      
      t.boolean :system, :default => false # Is a plugin or a ginst task
      t.datetime :started_at, :ended_at
      t.string :status, :default => 'prepared'
      t.integer :pid
      t.text :output
      t.integer :exit_code
      
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
