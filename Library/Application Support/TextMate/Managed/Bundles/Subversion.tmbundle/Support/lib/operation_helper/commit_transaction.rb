require ENV['TM_BUNDLE_SUPPORT'] + "/lib/subversion"
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + "/lib/ui"
require ENV['TM_SUPPORT_PATH'] + "/lib/tm/process"
require ENV['TM_SUPPORT_PATH'] + "/lib/progress"
require 'shellwords'

module Subversion

  class CommitTransaction

    attr_accessor :base
    attr_accessor :paths
    attr_accessor :status
    attr_accessor :show_progress

    def initialize(base, paths)
      @base = (@base =~ /\/$/) ? base : "#{base}/"
      Dir.chdir(@base)
      @paths = paths
      @status = Subversion.status(@paths)
      @diff = ENV['TM_SVN_DIFF_CMD'] || 'diff'
      @commit_window = ENV['CommitWindow'] || ENV['TM_SCM_COMMIT_WINDOW']
      @commit_helper = ENV['TM_BUNDLE_SUPPORT'] + "/bin/commit_helper.rb"
      @show_progress = false
    end

    def has_mods?
      not @status.paths.empty?
    end
    
    def relative_paths
      escaped_base = Regexp.escape(@base)
      paths.map { |p| p.sub(/^#{escaped_base}/, '') }
    end
    
    def commit()
      
      out, err = ::TextMate::Process.run(
        @commit_window,
        "--diff-cmd", "#{File.dirname(__FILE__)}/../../bin/diff.rb,--revision=BASE,--external",
        "--status", @status.commit_window_code_string,
        "--action-cmd", "!:Remove,#{@commit_helper},rm",
        "--action-cmd", "?:Add,#{@commit_helper},add",
        "--action-cmd", "A:Mark Executable,#{@commit_helper},propset,svn:executable,true",
        "--action-cmd", "A,M,D,C:Revert,#{@commit_helper},revert",
        "--action-cmd", "C:Resolved,#{@commit_helper},resolved",
        Subversion.esc(@status.paths(@base))
      )
      abort "Commit Window produced an error: #{err}" unless err.empty?
      
      commit_args = Shellwords.shellwords(out)
      
      if ($? != 0)
        nil # User cancelled
      else
        result = nil
        commit = proc { result = Subversion.commit("--force-log", *commit_args) }
        if show_progress
          TextMate.call_with_progress(:title => 'Subversion Commit', :message => 'Transmitting file data…', &commit)
        else
          commit.call
        end
        result
      end
    end

  end
end