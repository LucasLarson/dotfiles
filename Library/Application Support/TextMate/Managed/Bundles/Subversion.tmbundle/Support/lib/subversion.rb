require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress'

dir = File.dirname(__FILE__)
require dir + '/model/status_listing'
require dir + '/model/commit_result'
require dir + '/model/log'
require dir + '/model/update_result'
require dir + '/model/checkout_result'
require dir + '/model/info'
require dir + '/model/blame'
require 'pathname'

module Subversion
  class << self

    def svn
      ENV['TM_SVN'] || 'svn'
    end

    def esc(value)
      if value.kind_of?(Array)
        value.map { |element| esc(element) }
      elsif value.kind_of?(Pathname)
        esc(value.to_s)
      elsif value.kind_of?(String) && value =~ /@/
        value + '@'
      else
        value
      end
    end

    def run(*cmd, &error_handler)
      out, err = TextMate::Process.run(svn, cmd, :buffer => false)
    
      if error_handler.nil?
        if $? != 0
          if err =~ /'(.+)' is not a working copy/
            path = Pathname.new($1).realpath
            TextMate::UI.alert(:critical, "#{cmd.first.capitalize} Unavailable", "'#{path}' is not a working copy.", "OK")
          else
            TextMate::UI.alert(:critical, "The 'svn' command produced an error", err, "OK")
          end
          exit 1
        end
      else
        error_handler.call($?, err)
      end
      out
    end
    
    def status(*dirs) 
      out = Subversion.run("status", "--xml", *dirs) do |status,err| 
        if err =~ /'(.+)' is not a working copy/
          path = Pathname.new($1).realpath
          TextMate::UI.alert(:critical, "Status Unavailable", "'#{path}' is not a working copy.", "OK")
          exit 1
        end
      end
      StatusListing::XmlParser.new(out).status
    end
    
    def commit(*args)
      CommitResult.new(Subversion.run("commit", *args))
    end
    
    def log(file, user_options = {})
      options = {:quiet => false, :verbose => false}.merge! user_options
      cmd = ["log", "--xml"]
      ["-l", options[:limit].to_s].each { |e| cmd << e } unless options[:limit].nil?
      ["-r", options[:revision].to_s].each { |e| cmd << e } unless options[:revision].nil?
      cmd << '--verbose' if options[:verbose]
      cmd << file
      log_getter = Proc.new { Subversion::Log::XmlParser.new(Subversion.run(*cmd)).log }
      if options[:quiet]
        log_getter.call
      else
        TextMate::call_with_progress(:title => "svn log", :message => "Reading log of “#{File.basename(file)}”", &log_getter)
      end
    end
    
    def update(base, files, user_options = {})
      options = {:quiet => false}.merge! user_options
      result = nil
      updater = Proc.new do
        Dir.chdir(base) do
          update_text = Subversion.run("update", *files)
          result = Subversion::UpdateResult::PlainTextParser.new(base, update_text).update_result
        end
      end        
      if options[:quiet]
        updater.call
      else
        TextMate::call_with_progress(
          :title => "svn update", 
          :message => "Updating #{File.basename(base)}#{" (selection)" unless files.empty?}…", 
          &updater
        )
      end
    end
    
    def checkout(base, url, user_options = {})
      options = {:quiet => false}.merge! user_options
      checkouter = Proc.new do
        Dir.chdir(base) do
          Subversion::CheckoutResult::PlainTextParser.new(base, Subversion.run("checkout", url, ".")).checkout_result
        end
      end        
      if options[:quiet]
        checkouter.call
      else
        TextMate::call_with_progress(
          :title => "svn checkout", 
          :message => "Checking out #{url}", 
          &checkouter
        )
      end
    end

    def diff_files(base, revision, files, user_options = {})
      options = {:quiet => false}.merge! user_options
      if base
        base = Pathname.new(base)
        files = files.map do |f| 
          p = Pathname.new(f)
          (p.relative?) ? p.to_s : p.relative_path_from(base).to_s
        end
      end
      differ = Proc.new do
        Dir.chdir(base) { Subversion.run("diff", (ENV['TM_SVN_DIFF_CMD'] ? "--diff-cmd=#{ENV['TM_SVN_DIFF_CMD']}" : nil), "-r", revision, *files) }
      end
      if revision == 'BASE' or options[:quiet]
        differ.call
      else
        TextMate::call_with_progress(:title => "svn diff", :message => "Fetching diff (#{revision})", &differ)
      end
    end

    def info(base, *files)
      Dir.chdir(base) do
        Subversion::Info::XmlParser.new(Subversion.run("info", "--xml", *files)).info
      end      
    end

    def cat(target, revision, user_options = {})
      options = {:quiet => false}.merge! user_options
      catter = Proc.new { Subversion.run("cat", "--revision", revision, target) }
      if options[:quiet]
        catter.call
      else
        TextMate::call_with_progress(
          :title => "svn cat", 
          :message => "Fetching #{File.basename(target).sub(/\@.+$/, '')} @ revision #{revision}", 
          &catter
        )
      end
    end

    def diff_url(url, revision, user_options = {})
      options = {:quiet => false, :change => false}.merge! user_options
      differ = Proc.new do
        Subversion.run("diff", (options[:change] ? "-c" : "-r"), revision, (ENV['TM_SVN_DIFF_CMD'] ? "--diff-cmd=#{ENV['TM_SVN_DIFF_CMD']}" : nil), url)
      end
      if options[:quiet]
        differ.call
      else
        TextMate::call_with_progress(:title => "svn diff", :message => "Fetching diff (#{revision})", &differ)
      end
    end

    def blame(base, files, user_options = {})
      options = {:quiet => false}.merge! user_options
      if base
        base = Pathname.new(base)
        files = files.map do |f|
          p = Pathname.new(f)
          (p.relative?) ? p.to_s : p.relative_path_from(base).to_s
        end
      end
      blame_xml = ""
      file_contents = {}
      logs = {}

      blamer = Proc.new do
        Dir.chdir(base) do
          blame_xml = Subversion.run("blame", "--xml", *files)
          files.each do |f|
            file_contents[f] = Subversion.run("cat", "--revision", "BASE", f)
            logs[f] = Subversion.log(f, :quiet => true)
          end
        end
      end

      if options[:quiet]
        blamer.call
      else
        TextMate::call_with_progress(:title => "svn blame", :message => "Fetching blame…", &blamer)
      end

      Subversion::Blame::XmlParser.new(blame_xml, file_contents, logs).blame
    end
  end
end