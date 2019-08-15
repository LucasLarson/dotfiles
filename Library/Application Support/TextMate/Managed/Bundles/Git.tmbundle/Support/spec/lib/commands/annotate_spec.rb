require File.dirname(__FILE__) + '/../../spec_helper'

describe SCM::Git do
  before(:each) do
    @annotate = Git.new
  end
  include SpecHelpers
  
  describe "when parsing a annotate" do
    before(:each) do
      @lines = @annotate.parse_annotation(File.read("#{FIXTURES_DIR}/annotate.txt"))
    end
    
    it "should parse out all items" do
      @lines.should have(428).entries
    end
    
    it "should parse out the author, msg, and revision" do
      line = @lines.first
      line[:rev].should == "26e2d189"
      line[:filepath].should be_nil
      line[:author].should == "Tim Harper"
      line[:date].should == Time.parse("2008-03-02 00:24:40 -0700")
      line[:text].should == 'require LIB_ROOT + "/parsers.rb"'
    end
  end
  
  describe "when parsing a annotate with a RENAMED file" do
    before(:each) do
      @lines = @annotate.parse_annotation(File.read("#{FIXTURES_DIR}/annotate_renamed.txt"))
    end
    
    it "should parse out all items" do
      @lines.should have(428).entries
    end
    
    it "should parse out the author, msg, and revision" do
      line = @lines.first
      line[:rev].should == "26e2d189"
      line[:filepath].should == "Support/lib/git.rb"
      line[:author].should == "Tim Harper"
      line[:date].should == Time.parse("2008-03-02 00:24:40 -0700")
      line[:text].should == 'require LIB_ROOT + "/parsers.rb"'
    end
  end
end
