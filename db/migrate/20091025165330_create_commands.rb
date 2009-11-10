class CreateCommands < ActiveRecord::Migration
  def self.up
    create_table :commands do |t|
      t.references :task
      t.integer :position
      
      t.string :name
      t.boolean :system, :default => false
      t.text :command
      t.text :output
      t.integer :exit_code
      t.datetime :started_at, :ended_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :task_commands
  end
end
