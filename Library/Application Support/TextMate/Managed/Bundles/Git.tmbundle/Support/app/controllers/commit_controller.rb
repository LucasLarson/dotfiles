require LIB_ROOT + '/partial_commit_worker.rb'
class CommitController < ApplicationController
  layout "application", :except => [:add]

  def index
    if git.merge_message
      @status = git.status
      @message = git.merge_message
      render "merge_commit"
    else
      run_partial_commit
    end
  end

  def merge_commit
    message = params[:message]
    statuses = git.status(git.path)
    files = statuses.map { |status_options| (status_options[:status][:short] == "G") ? git.make_local_path(status_options[:path]) : nil }.compact

    git.auto_add_rm(files)
    res = git.commit(message, [])

    render "_commit_result", :locals => { :result => res, :files => files, :message => message }
  end

  def add
    paths = git.paths(:unique => true, :fallback => :current_file)
    git.add(paths)
    paths.each { |file| puts "Added '#{git.relative_path_for(file)}' to the index" }
    exit_show_tool_tip
  end

  protected
    def run_partial_commit
      puts "<h2>#{commit_worker.title}…</h2>"
      result = commit_worker.run
      render "_commit_result", :locals => result if result
    rescue PartialCommitWorker::NotOnBranchException
      render "not_on_a_branch"
      false
    rescue PartialCommitWorker::NothingToCommitException
      puts(git.clean_directory? ? "Working directory is clean (nothing to commit)" : "No changes to commit within the current scope. (Try selecting the root folder in the project drawer?)")
    rescue PartialCommitWorker::NothingToAmendException
      puts "Nothing to amend."
    rescue PartialCommitWorker::CommitCanceledException
      suppress_output
    end

    def commit_worker
      @commit_worker ||= PartialCommitWorker.factory(params[:type], git)
    end
end