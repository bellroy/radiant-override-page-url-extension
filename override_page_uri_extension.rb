# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class OverridePageUriExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/override_page_uri"
  
  # define_routes do |map|
  #   map.connect 'admin/override_page_uri/:action', :controller => 'admin/override_page_uri'
  # end
  
  def activate
    # admin.tabs.add "Override Page Uri", "/admin/override_page_uri", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Override Page Uri"
  end
  
end