require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  it "should have a url" do
    Page.should respond_to(:url)
  end
end
