require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageController, "with url_override" do
  scenario :users, :home_page
  test_helper :pages, :page_parts, :caching

  integrate_views

  before :each do
    login_as :existing
    create_page 'page without url override'
    create_page 'page with url override', :url_override => '/url/override/'
  end
  
  it "should display a url_override field in extended meta data" do
    get :edit, :id => pages(:page_without_url_override).id
    response.body.should have_tag("div#extended-metadata") do |elements|
      elements.should have_tag("label[for='page_url_override']")
      elements.should have_tag("input#page_url_override[name='page[url_override]']")
    end
  end
  
  it "should populate the url_override from the page" do
    get :edit, :id => pages(:page_with_url_override).id
    response.body.should have_tag("input#page_url_override[value=/url/override/]")
  end
  
  
end
