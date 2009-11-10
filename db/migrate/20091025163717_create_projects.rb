class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :repo
      t.string :name
      t.string :slug
      
      t.text :preferences
      
      t.string :status, :default => 'preparing'
      t.datetime :last_build
      t.datetime :locked_at
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
