# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091025165330) do

  create_table "commands", :force => true do |t|
    t.integer  "task_id"
    t.integer  "position"
    t.string   "name"
    t.boolean  "system",     :default => false
    t.text     "command"
    t.text     "output"
    t.integer  "exit_code"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "repo"
    t.string   "name"
    t.string   "slug"
    t.text     "preferences"
    t.string   "status",      :default => "preparing"
    t.datetime "last_build"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "project_id"
    t.string   "commit_sha1"
    t.text     "code"
    t.integer  "priority",                          :default => 20
    t.text     "on_success"
    t.text     "on_failure"
    t.boolean  "system",                            :default => false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string   "status",                            :default => "prepared"
    t.integer  "pid"
    t.text     "output",      :limit => 2147483647
    t.integer  "exit_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
