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
        page_url_override_is_valid! " leading_space_ok"
      end
  
      it "should be valid with a url with trailing spaces" do
        page_url_override_is_valid! "trailing_space_ok "
      end
    
      it "should be valid if the url_override is nil" do
        page_url_override_is_valid! nil
      end
    
      it "should be valid if the url_override is valid" do
        page_url_override_is_valid! "/good/url_override"
      end
      
      it "should be invalid if the url_override is too long" do
        page_url_override_is_valid! "/#{"a"*197}/" # 199 characters including /../
        page_url_override_is_valid! "/#{"a"*198}/" # 200 ...
        page_url_override_is_invalid! "/#{"a"*199}/" #201 ...
        page_url_override_is_invalid! "/#{"a"*200}/" #202 ...
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
    
    context "slug" do
      context "validation" do
        
        before(:each) do
          create_page 'parent page', :slug => 'parent_page' do
            create_page 'child page 1', :slug => 'child_page1'
          create_page 'url_override_page', :slug => 'url_override', :url_override => '/parent_page/bar/'
          end
        end
        
        def slug_is_invalid!(slug, url_override=nil)
          p = Page.new(:slug => slug, :url_override => url_override, :parent => pages(:parent_page))
          p.valid?
          p.errors.on(:slug).should_not be_blank
        end
        
        def slug_is_valid!(slug, url_override=nil)
          p = Page.new(:slug => slug, :url_override => url_override, :parent => pages(:parent_page))
          p.valid?
          p.errors.on(:slug).should be_blank
        end
        
        context "when no url_override is set" do
          it "should be valid if the generated URL for the page does not duplicate another generated URL or overridden url" do
            slug_is_valid!('ok')
          end
          it "should be invalid if the generated URL for the page duplicates another overriden URL" do
            slug_is_invalid!('bar')
          end
          it "should be invalid if the generated URL for the page duplicates another generated URL" do
            slug_is_invalid!('child_page1')
          end
        end
        
        context "when url_override is set" do
          it "should be valid if the generated URL for the page does not duplicate another generated URL or overridden url" do
            slug_is_valid!('ok', '/parent_page/foo/')
          end
          it "should be invalid if the slug URL for the page duplicates another slug" do
            slug_is_invalid!('child_page1', '/parent_page/foo/')
          end
          it "should be valid if the generated URL for the page duplicates another generated URL" do
            slug_is_valid!('bar', '/parent_page/foo/')
          end
        end
      end
    end
  
  
    context "auto data correction" do
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
      
      it "should strip leading/trailing spaces" do
        @page.url_override = ' /url_with_leading_trailing_spaces/ '
        @page[:url_override].should == '/url_with_leading_trailing_spaces/'
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
  
  context "find_by_url" do
    
    before(:each) do
      create_page 'parent page', :slug => 'parent_page' do
        create_page 'published page without override', :slug => 'published_page_without_override', :status_id => Status[:published].id
        create_page 'draft page without override', :slug => 'draft_page_without_override', :status_id => Status[:draft].id
        create_page 'published page with override', :slug => 'published_page_with_override', :status_id => Status[:published].id, :url_override => '/foo/published/'
        create_page 'draft page with override', :slug => 'draft_page_with_override', :status_id => Status[:draft].id, :url_override => '/bar/draft/'
      end
    end
    
    it "should default live to true if not specified" do
      non_published_page = '/parent_page/draft_page/'
      Page.find_by_url(non_published_page).should == Page.find_by_url(non_published_page, true)
      Page.find_by_url(non_published_page).should != Page.find_by_url(non_published_page, false)
    end
    
    context "on pages without url_override" do
      context "that are unpublished" do
        it "should not be found at their generated url in live mode" do
          Page.find_by_url('/parent_page/draft_page_without_override/').should be_blank
        end
        it "should be found at their generated url in dev mode" do
          Page.find_by_url('/parent_page/draft_page_without_override/', false).should == pages(:draft_page_without_override)
        end
      end

      context "that are published" do
        it "should be found at their generated url in live mode" do
          Page.find_by_url('/parent_page/published_page_without_override/').should == pages(:published_page_without_override)
        end
        it "should be found at their generated url in dev mode" do
          Page.find_by_url('/parent_page/published_page_without_override/', false).should == pages(:published_page_without_override)
        end
      end
    end
    
    context "on pages with url_override" do
      context "that are unpublished" do
        it "should not be found at their url_override in live mode" do
          Page.find_by_url('/bar/draft/').should be_nil
        end

        it "should be found at their url_override in dev mode" do
          Page.find_by_url('/bar/draft/', false).should == pages(:draft_page_with_override)
        end
      end
      context "that are published" do
        it "should be found at their url_override in live mode" do
          Page.find_by_url('/foo/published/').should == pages(:published_page_with_override)
        end

        it "should be found at their url_override in dev mode" do
          Page.find_by_url('/foo/published/', false).should == pages(:published_page_with_override)
        end
      end
    end
    
  end
  
end
