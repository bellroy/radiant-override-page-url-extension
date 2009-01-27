require 'page'

module PageUrlOverride
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
    receiver.class_eval do
      validate :validate_url_override_is_a_valid_uri
      validate :validate_url_override_uniqueness
      
      # guard alias_method_chain calls, OverridePageUriExtension#activate can be called multiple times (at least in dev mode)
      # and will result in stack overflow if methods aliased with the same thing more than once.
      alias_method_chain :url, :generated_override unless instance_methods.include?('url_without_generated_override')      
      class << self
        alias_method_chain :find_by_url, :generated_override unless instance_methods.include?('find_by_url_without_generated_override')
      end
      
    end
  end
  
  module ClassMethods
    def find_by_url_with_generated_override(url, live = true)
      clean_url = "/#{ url.strip }/".gsub(%r{//+}, '/') 
      conditions = {:url_override => clean_url}
      conditions[:status_id] = Status[:published].id if live
      page = Page.find(:first, :conditions => conditions)
    
      return page if page
      
      find_by_url_without_generated_override(url, live)
    end
  end
  
  module InstanceMethods
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

    def url_with_generated_override
      return url_override unless url_override.blank?
      url_without_generated_override
    end
  end
  
end