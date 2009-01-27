require File.dirname(__FILE__) + '/../spec_helper'

describe SiteController, "with url_override" do
  scenario :users, :home_page
  test_helper :pages, :page_parts, :caching

  integrate_views

  before :each do
    login_as :existing
    create_page 'page without url override', :slug => 'page_without_url_override'
    create_page 'page with url override', :url_override => '/url/override/'
  end
  
  it "should display the page at an overriden url" do
    params = params_from(:get, '/url/override/')
    get params[:action], :url => params[:url]
    assigns[:page].should == pages(:page_with_url_override)
  end
  
  it "should display the page without an overridden url" do
    params = params_from(:get, '/page_without_url_override/')
    get params[:action], :url => params[:url]
    assigns[:page].should == pages(:page_without_url_override)

  end
  
end
