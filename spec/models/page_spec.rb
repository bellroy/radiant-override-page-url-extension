require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  
  scenario :home_page
  
  before(:each) do
    @page = Page.new
  end
  
  it "should have a url_override" do
    @page.should respond_to(:url_override)
  end
  
  context "url_override" do
  
    context "validation" do
      def page_url_override_is_invalid!(bad_url_override)
        page = Page.new(:url_override => bad_url_override)
        page.url_override = bad_url_override
        page.slug = 'about_a_slug'
        page.valid?
        page.errors.on(:url_override).should_not be_blank
      end
    
      def page_url_override_is_valid!(good_url_override)
        page = Page.new(:url_override => good_url_override)
        page.url_override = good_url_override
        page.slug = 'about_a_slug'
        page.valid?
        page.errors.on(:url_override).should be_blank
      end
  
      it "should not be valid with a url with spaces" do
        page_url_override_is_invalid! "BAD URL IS BAD"
      end
  
      it "should be valid with a url with leading spaces" do
        page_url_override_is_valid! "leading_space_bad"
      end
  
      it "should be valid with a url with trailing spaces" do
        page_url_override_is_valid! "trailing_space_bad"
      end
    
      it "should be valid if the url_override is nil" do
        page_url_override_is_valid! nil
      end
    
      it "should be valid if the url_override is valid" do
        page_url_override_is_valid! "/good/url_override"
      end
    
      context "for duplicate" do
        before(:each) do
          create_page 'parent page', :slug => 'parent_page' do
            create_page 'child page 1', :slug => 'child_page1'
          end
        end
      
        it "should be valid if url_override does not duplicate existing url at all" do
          page_url_override_is_valid! '/some_parent/some_page/'
        end
      
        it "should be valid if url_override path duplicates another path, but 'file' does not" do
          page_url_override_is_valid! '/parent_page/some_page/'
        end
      
        it "should be valid if url_override 'file' duplicates existing page, but path does not" do
          page_url_override_is_valid! '/some_parent/child_page1/'
        end
      
        it "should not be valid if url_override duplicates an existing url" do
          page_url_override_is_invalid! '/parent_page/child_page1/'
        end
      
      end
    end
  
  
    context "leading/trailing forward slash handling" do
      it "should append a trailing forward slash if one is missing" do
        @page.url_override = '/url/override'
        @page.url_override.should == '/url/override/'
      end
  
      it "should not append a trailing forward slash if one is provided" do
        @page.url_override = '/url/override/'
        @page.url_override.should == '/url/override/'
      end
  
      it "should prepend a leading forward slash if one is missing" do
        @page.url_override = 'url/override/'
        @page.url_override.should == '/url/override/'
      end
  
      it "should not prepend a leading forward slash if one is provided" do
        @page.url_override = '/url/override/'
        @page.url_override.should == '/url/override/'
      end
    
      it "should not prepend or append a forward slash if url_override is nil" do
        @page.url_override = nil
        @page.url_override.should be_nil
      end
    end
  end
  
  context "url" do
    before(:each) do
      @page.slug = 'about_a_slug'
    end
    
    context "when url_override is nil" do
      before(:each) do
        @page.url_override = nil
      end
      
      it "should generate url normally from slug and parent when the page has a parent" do
        @page.parent = Page.new(:slug => 'i_am_a_parent')
        @page.url.should == '/i_am_a_parent/about_a_slug/'
      end
    
      it "should generate url normally from slug when the page has not parent"do
        @page.url.should == '/about_a_slug/'
      end
    end
    
    context "when url_override is not nil" do
      before(:each) do
        @page.url_override = '/url/override'
      end
      
      it "should return url from url_override when page has no parent" do
        @page.url.should == '/url/override/'
      end
      
      it "should return url from url_override when page has a parent" do
        @page.parent = Page.new(:slug => 'i_am_a_parent')
        @page.url.should == '/url/override/'
      end
    end
    
  end
  
end
