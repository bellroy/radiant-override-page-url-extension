require File.dirname(__FILE__) + '/../spec_helper'

describe "url_override_extension" do
  # check behaviour of http://github.com/tricycle/radiant-trike-tags-extension is preserved when used with this plugin
  if Radiant::Extension.descendants.map{|e| e.name}.include?("TrikeTagsExtension")
    
    scenario :home_page
    
    before(:each) do
      create_page "page_without_url_override", :slug => "page_without"
      create_page "page_with_url_override", :slug => "page_with", :url_override => "/foo/bar/"
    end
    
    context "when trailing slash not used by default" do
      before(:each) do
        Radiant::Config['defaults.trailingslash'] = 'n' 
      end
      
      it "should not append a trailing slash for default generated urls" do
        pages(:page_without_url_override).should render("<r:url />").as("/page_without")
      end
      
      it "should not append a trailing slash for overridden urls" do
        pages(:page_with_url_override).should render("<r:url />").as("/foo/bar")
      end
    end
    
    context "when trailing slash is used by default" do
      before(:each) do
        Radiant::Config['defaults.trailingslash'] = 'y' 
      end
      
      it "should not append a trailing slash for default generated urls" do
        pages(:page_without_url_override).should render("<r:url />").as("/page_without/")
      end
      
      it "should append a trailing slash for overridden urls" do
        pages(:page_with_url_override).should render("<r:url />").as("/foo/bar/")
      end
    end
    
  end
end