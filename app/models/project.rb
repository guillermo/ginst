class Project < ActiveRecord::Base
  include Slugify
  
  has_many :tasks, :order => 'updated_at desc, system desc, priority ASC'
  delegate :prepared, :to => :tasks, :prefix => :tasks

  after_create :create_setup_task
  before_create :create_secret
  
  validates_presence_of :name, :repo
  validates_associated :tasks
  serialize :preferences
  
  slugify :name
  
  # attribute_choices :status, {'preparing' => "Project not ready",
  #                             'building' => "Building",
  #                             'prepared' => "Prepared"}
  # 
  
  class ProjectLockedException < Exception ; end
  
  def building?
    status == 'building'
  end
  

  def run_tasks!    
    if !:locked_at || !tasks_prepared.empty?
      update_attribute(:locked_at, Time.current)

      tasks.prepared.each do |task|
        Rails.logger.info " Running #{task.name.to_s+' '}task #{task.id} for #{slug}"
        task.execute
        Rails.logger.info " Finish running #{task.name.to_s+' '}task #{task.id} for #{slug}"
      end
      update_attributes(:locked_at => nil, :last_build => Time.current)
    end    
  end
  
  
  def create_fetch_task
    current_fetch_task = tasks.unfinished.fetch_tasks.first
    return current_fetch_task if current_fetch_task
    
    Rails.logger.debug "[#{Time.current.to_s(:small)}] * Creating repo for #{name}"

    command = "cd #{local_repo_dir}
    git fetch -fv origin
    "

    tasks.create(
      :name => 'fetch.sh',
      :system => true,
      :code => command,
      :on_success => "Project.find(#{id}).process_new_heads"
    )
  end
  
  def process_new_heads
    preferences.branch_status ||= {}
    #look for changes in heads
    branchs.each do |branch|
      unless (branch.commit.id == preferences.branch_status[branch.name])
        process_new_head(branch)
        preferences.branch_status[branch.name] = branch.commit.id
        save
      end
    end
  end
  
  def process_new_head(branch)
    logger.info("Processing new commit for #{branch.name}, #{branch.commit.id} ")
    plugins.each do |plugin|
      plugin.on_commit(self, branch) if plugin.respond_to? :on_commit
    end
  end
    
  def plugins
    Ginst::Plugin.plugins
  end
  
  def create_setup_task
    Rails.logger.debug "[#{Time.current.to_s(:small)}] * Creating repo for #{name}"

    command = "
    echo removing previous repo
    rm -Rf #{local_repo_dir}
    if [ ! -d #{project_dir} ] 
    then
      echo Creating dir #{project_dir}
      mkdir -p #{project_dir} 
    fi
    echo Clonning repo &&
    git clone --mirror --verbose #{repo} #{local_repo_dir} 
    "
    tasks.create(
      :name => 'setup_repo.sh',
      :system => true,
      :code => command,
      :on_success => "p = Project.find(#{id}) ; p.set_default_tracking_branchs ; p.update_attribute(:status, 'prepared') "
    )  
  end
    
    
      
  def to_param
    slug
  end
    
  def grit_repo
    @grit_repo || Grit::Repo.new(local_repo_dir)
  rescue Grit::NoSuchPathError
    nil
  end
  
  def heads
    grit_repo && grit_repo.heads
  end
  
  def branchs
    heads && heads.select do |head|
      tracking_branches.include? head.name 
    end
  end
  
  def tracking_branches
    preferences.tracking_branches ||= []
    preferences.tracking_branches
  end
      
  def set_default_tracking_branchs
    preferences.tracking_branches = heads.map(&:name).join(", ")
    save
  end
  
  def preferences
    unless read_attribute(:preferences).kind_of? OpenStruct
      write_attribute(:preferences,OpenStruct.new)
      read_attribute(:preferences)
    else
      read_attribute(:preferences)
    end
  end
  
  def preferences=(value)
    case value
    when Hash
      value.each {|k,v|
        preferences.send("#{k.to_s}=",v)
      }
    when OpenStruct
      self[:preferences] = value
    else
      raise 'NO NO'
    end
    preferences    
    
  end
  
  def commits(*args)
    grit_repo.commits(*args)
  end
  
  def commit(sha1)
    grit_repo.commit(sha1)
  end
  
  def commits_between_dates(from,to)
    grit_repo.commits_between_dates(from,to)
  end
    
  def project_dir
    File.join(Ginst.data_dir,'projects')
  end
  
  def local_repo_dir
    File.join(project_dir,"#{slug}.git")
  end
  
  def tmp_repo_dir
    File.join(project_dir,'tmp',slug)
  end
  
  
  def secret
    preferences.secret
  end
  
  def create_secret
    preferences.secret = random_secret
  end
  
  def random_secret
    keys = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
    Array.new(8).map{ keys[rand(keys.size)] }.join
  end
  
end

