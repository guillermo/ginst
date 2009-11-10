class SimpleBuild < Task
  
  
  def self.create_for_branch(project,branch)
    create_for_commit(project,branch.commit)
  end
  
  def self.create_for_commit(project,commit)
    build = SimpleBuildConf.new(project.slug).build
    command = "
    cd #{project.project_dir}
    if [ -d #{project.tmp_repo_dir} ]
    then
      rm -Rf #{project.tmp_repo_dir}
    fi
    git clone -s -n #{project.local_repo_dir} #{project.tmp_repo_dir}
    cd #{project.tmp_repo_dir}
    git checkout #{commit.id}
    echo 'building (#{commit.id})'
    #{build}
    "
      
    SimpleBuild.create(
      :name => "Simple build for #{commit.id}.sh",
      :code => command,
      :commit_sha1 => commit.id,
      :project => project)
  end
end