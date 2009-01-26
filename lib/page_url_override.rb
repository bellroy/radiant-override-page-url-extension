# This was done as a mixin module making use of alias_method_chain rather than monkey patching the Page class, 
# but there were issues with infinite recursion. Running alias_method_chain on class level
# methods mixed in from a Module wouldn't work, and it would just call the same method over and over.
#
# TODO see if this can be fixed up to use the mixin approach again. 
# This implementation uses copy/paste of the Radiant Page methods #find_by_url and #url methods
# with extra logic added to handle url_override. However this is fragile, and will cause problems
# if the radiant implementation of these methods change in the future. alias_method_chain would
# be preferable if it can be made to work.
class Page < ActiveRecord::Base
  
  class << self
    def find_by_url(url, live = true)
      clean_url = "/#{ url.strip }/".gsub(%r{//+}, '/') 
      page = Page.find(:first, :conditions => ["url_override = ?", clean_url])
    
      return page if page
      
      root = find_by_parent_id(nil)
      raise MissingRootPageError unless root
      root.find_by_url(url, live)
    end
  end
  
  def validate_url_override_is_a_valid_uri
    begin
      return unless url_override
      URI.parse(url_override)
      return true
    rescue URI::InvalidURIError
      errors.add(:url_override, "is invalid")
    end
  end
  
  def validate_url_override_uniqueness
    return if url_override.blank?
    
    existing_duplicate = Page.find_by_url(url)
    # we're ok if we find ourselves, or if we find nothing - there is no duplicate
    return if existing_duplicate.nil? || existing_duplicate == self || FileNotFoundPage === existing_duplicate
    
    errors.add(:url_override, "results in non unique url")
  end

  def url_override=(a_url_override)
    unless a_url_override.blank?
      a_url_override.strip!
      a_url_override = clean_url(a_url_override)
    end
    self[:url_override] = a_url_override
  end
  
  def url
    return url_override unless url_override.blank?
    
    if parent?
      parent.child_url(self)
    else
      clean_url(slug)
    end
  end
  
end