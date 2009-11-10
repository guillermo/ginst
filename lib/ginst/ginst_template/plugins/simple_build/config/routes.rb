
ActionController::Routing::Routes.draw do |map|

  map.resources :projects do |project|
    project.resources :simple_builds, :collection => {:config => 'get', :config => 'post'}
  end
  
  
end