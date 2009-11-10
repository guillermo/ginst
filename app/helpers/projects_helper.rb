module ProjectsHelper
  
  def show_branch_links
    content_tag :ul, :id => 'heads', :class => 'tabs' do
      @project.branchs.map{ |h|
        content_tag :li do
          link_to_unless params["branch"]==h.name,  h.name,"?branch=#{h.name}"
        end
      }
    end
  end
  
  def gravatar_url_for(commit, size = 30)
    md5 = Digest::MD5.hexdigest(commit.author.email.strip.downcase)
    "http://www.gravatar.com/avatar/#{md5}?s=30"
  end
  
  def show_time(time)
    return nil unless time
    case
    when time > Time.current.beginning_of_day
      time.to_s(:short)
    when time > 7.days.ago
      time_ago_in_words(time,true)
    when time > 1.year.ago
      time.to_s(:short)
    else
      time.to_s(:long)
    end
  end
  
  def project
    @project
  end
  
  def plugins_links
    Ginst::Plugin.paths.map {|name,path|
        content_tag :li, link_to(name, instance_eval(&path)) 
    }
  end
    
end
