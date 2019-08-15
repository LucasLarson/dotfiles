require File.dirname(__FILE__) + '/../spec_helper'
require LIB_ROOT + "/partial_commit_worker"

describe PartialCommitWorker do
  include SpecHelpers
  before(:each) do
    @git = Git.singleton_new
  end

  describe "Commit" do
    before(:each) do
      @commit_worker = PartialCommitWorker::Normal.new(@git)
    end

    it "should NOT be OK to proceed when not on a branch but performing an initial commit" do
      @git.branch.should_receive(:current_name).and_return(nil)
      @git.should_receive(:initial_commit_pending?).and_return(false)
      @commit_worker.ok_to_proceed_with_partial_commit?.should == false
    end

    it "should be OK to proceed when not on a branch but performing an initial commit" do
      @git.branch.should_receive(:current_name).and_return(nil)
      @git.should_receive(:initial_commit_pending?).and_return(true)
      @commit_worker.ok_to_proceed_with_partial_commit?.should == true
    end

    it "should be NOT be OK to process when there are no file candidates" do
      @commit_worker = @commit_worker
      @commit_worker.stub!(:file_candidates).and_return([])
      @commit_worker.nothing_to_commit?.should == true
    end

    it "should NOT send the last commit message to the commit window when committing" do
      @git.stub!(:log).and_return([{:msg => "My Message"}])
      @commit_worker.stub!(:file_candidates).and_return([])
      @commit_worker.stub!(:status_helper_tool).and_return("/path/to/status_helper_tool")
      @output = @commit_worker.tm_scm_commit_window
      @output.should_not include(Shellwords.escape("My Message"))
    end
  end

  describe "Amend" do
    before(:each) do
      @commit_worker = PartialCommitWorker::Amend.new(@git)
    end

    it "should NOT be OK to proceed when performing an initial commit" do
      @git.stub!(:initial_commit_pending?).and_return(true)
      @commit_worker.nothing_to_amend?.should == true
    end

    it "should be OK to amend the commit if there are no files candiates" do
      @commit_worker.stub!(:file_candidates).and_return([])
      @commit_worker.nothing_to_commit?.should == false
    end

    it "should send the last commit message to the commit window when amending" do
      @git.stub!(:log).and_return([{:msg => "My Message"}])
      @commit_worker.stub!(:file_candidates).and_return([])
      @commit_worker.stub!(:status_helper_tool).and_return("/path/to/status_helper_tool")
      @output = @commit_worker.tm_scm_commit_window
      @output.should include(Shellwords.escape("My Message"))
    end
  end

end
