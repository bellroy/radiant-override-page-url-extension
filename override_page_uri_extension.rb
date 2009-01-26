# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

# these need to required here for some reason, or radiant throws a tantrum
# whenever a new request is made (at least in development mode). Something to
# do with class loading order. Couldn't figure out exactly what was going on
# TODO get to the bottom of what's going on here. It should work without these.
require 'page_part'
require 'user'

# here is what we actually need to make the extension work
require 'page'
require 'lib/page_url_override'

class OverridePageUriExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/override_page_uri"
  
  def activate
    Page.send(:include, PageUrlOverride)
    admin.page.edit.add :extended_metadata, "url_override"
  end
  
  def deactivate
    # TODO how do we remove an admin page region partial?
  end
  
end