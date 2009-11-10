class Ginst::Ssh
  def self.public_keys
    if (files = public_key_files)
      keys = {}
      files.each {|f|
        keys[File.basename(f)] = File.read(f).strip
      }
      keys
    else
      {}
    end
  end  
  
  private
  def self.public_key_files
    ssh_dir = File.expand_path("~/.ssh")
    Dir.glob(ssh_dir+"/id_*.pub")
  end
end
