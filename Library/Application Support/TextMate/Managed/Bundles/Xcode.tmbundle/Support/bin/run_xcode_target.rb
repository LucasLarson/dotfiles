#!/usr/bin/env ruby18 -s
# encoding: utf-8

require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "#{ENV['TM_SUPPORT_PATH']}/lib/io"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_BUNDLE_SUPPORT']}/bin/xcode_version"
require 'open3'
require 'pty'
require "cgi" # so we have CGI.escapeHTML

class Xcode
  
  # N.B. lots of cheap performance wins to be made by aggressive (or any) caching.
  # Not clear it's worthwhile. Could also be stale if these objects live a long time and
  # the user makes changes to the project in Xcode.
  
  # project file
  class Project
    attr_reader :objects
    attr_reader :root_object
    
    def initialize(path_to_xcodeproj)
      @project_path = path_to_xcodeproj
      @project_data = OSX::PropertyList.load(File.new(path_to_xcodeproj + "/project.pbxproj"))
      @objects      = @project_data['objects']
      @root_object  = @objects[@project_data['rootObject']]
    end

    def user_settings_data
      user_file     = @project_path + "/#{`whoami`.chomp}.pbxuser"
      user          = OSX::PropertyList.load(File.new(user_file)) if File.exists?(user_file)
    end
        
    def active_configuration_name
      raise unless Xcode.supports_configurations?
      
      user            = user_settings_data
      active_config   = user && user[@project_data['rootObject']]['activeBuildConfigurationName']

      active_config || configurations.first.name
    end

		def configurations
			targets.first.configurations
		end

    def results_path
      # default to global build results
      default_dir = File.dirname(@project_path) + "/build"
      prefs = Xcode.preferences

      dir = [
        prefs['PBXProductDirectory'],
        (prefs['PBXApplicationwideBuildSettings'] || { })['SYMROOT'],
        default_dir
      ].map { |e| e && File.expand_path(e) }.find { |path| path && File.directory?(path) }
      
      # || user pref for SYMROOT + the active configuration
      if Xcode.supports_configurations? then
        user          = user_settings_data
        userBuild     = user && user[@project_data['rootObject']]['userBuildSettings']
        if userBuild && userBuild['SYMROOT']
          dir = userBuild['SYMROOT']
        end
        dir += "/#{active_configuration_name}"
      end
      dir
    end
    
    def targets
      @root_object['targets'].map { |t| Target.new(self, dereference(t)) }
    end
    
    def dereference(key)
      @objects[key]
    end

    def source_root
      root = @root_object['projectRoot']
      if root.nil? or root.empty?
        root = File.expand_path(File.dirname(@project_path))
      end
      root
    end

    def source_tree_for_group(group)
      type      = false
      path      = group['path']
      case group['sourceTree']
      when '<group>'
        type = :group
      when '<absolute>'
        type = :absolute
      when 'SOURCE_ROOT'
        path = source_root + "/" + path
        type = :source_root
      else
        puts "unknown sourceTree:#{group['sourceTree']}"
      end # case
      [type, path]
    end
    
    def nodepath_for_ref(ref, group, parents)      
      # maybe we're the parent
      return nil unless group['isa'] == 'PBXGroup'

      parents = parents.dup
      parents << group      

      children = group['children']
    
      # is the path in this group?
      if children.include?(ref) then
        return parents
      else
        out_parents = nil
        children.find do |child|
          out_parents = nodepath_for_ref(ref, dereference(child), parents)
          out_parents
        end
        out_parents
      end
    end
  
    
    def path_for_fileref(ref)
      # find the node path
      value = nodepath_for_ref(ref, dereference(@root_object['mainGroup']), Array.new) 
      return nil if value.nil?
      
      # create a filesystem path
      fs_path = source_root
      subpath = ''
			
      value.each do |group|
        type, segment = source_tree_for_group(group)
        unless type == :group
          fs_path = segment
				else
					if segment then
						subpath = subpath + "/" + segment
					end
        end
      end
			fs_path=fs_path+subpath
      fs_path
    end
    
    @@project_cache = { }     # to avoid loading/parsing sub-projects multiple times
    @@did_scan_project = [ ]  # to avoid scanning the same project multiple times (i.e. when it is included by sevearl sub-projects)
    @@in_sub_project = 0

    def path_for_basename(basename)
      @@did_scan_project = [ ] if @@in_sub_project == 0
      path = nil
      @objects.each_pair do |key, obj|

# 				Ever since Xcode 3 or so this block of code produces exceptions
# 				for me in the run log. But since I am not sure what it does, I
# 				am not comfortable removing it completely. However the Xcode
# 				bundle has worked fine for me for the past years without this block.
# 				
#         if obj['isa'] == 'PBXContainerItemProxy'
#           sub_project_file = dereference(obj['containerPortal'])['path']
#           sub_project_path = File.join(File.split(@project_path).first, sub_project_file)
#           sub_project_path = File.expand_path(sub_project_path)
# 
#           next if @@did_scan_project.include? sub_project_path
# 
#           unless @@project_cache.has_key? sub_project_path
#             @@project_cache[sub_project_path] = Xcode::Project.new sub_project_path
#           end
# 
#           sub_project = @@project_cache[sub_project_path]
#           @@did_scan_project << sub_project_path
#           @@in_sub_project += 1
#           path = sub_project.path_for_basename(basename)
#           @@in_sub_project -= 1
#           break if path
#         end

        next unless obj['isa'] == 'PBXFileReference'
        next unless obj['path'].include? '/' + basename or obj['path'] == basename
        path = path_for_fileref(key) + '/' + obj['path']
        break
      end
      path
    end
    
    # build configuration
    class BuildConfiguration
      def initialize(project, target, config_data)
        @project      = project
        @target       = target
        @config_data  = config_data
      end
      
      def name
        @config_data['name']
      end
      
      def setting(name)
        @config_data['buildSettings'][name]
      end
      
      def product_name
        setting('PRODUCT_NAME') || @target.name
      end
    end
    
    # targets
    class Target
    
      def initialize(project, target_data)
        @project      = project
        @target_data  = target_data
      end
      
      def name
        @target_data['name']
      end
      
      def configurations
        config_list = @project.dereference(@target_data['buildConfigurationList'])
        config_list = config_list['buildConfigurations']
        config_list.map {|config| BuildConfiguration.new(@project, self, @project.dereference(config)) }
      end
      
      def configuration_named(name)
        configurations.find { |c| c.name == name }
      end
      
      def product_path
        product_key = @target_data['productReference']
        product = @project.dereference(product_key)
        product['path']
      end
      
      def inspect
        "Target name:#{@target_data['name']}\nproductName:#{@target_data['productName']}\npath:#{product_path}\n---\n"
      end
      
      def product_type
        case @target_data['productType']
        when 'com.apple.product-type.application'
          :application
        when 'com.apple.product-type.tool'
          :tool
        end
      end
      
      def is_application?
        product_type == :application
      end
      
      def is_tool?
        product_type == :tool
      end
      
      def run(&block)
        dir_path  = @project.results_path.sub(/^\$HOME/,ENV['HOME'])
        file_path = product_path
        escaped_dir = e_sh(File.expand_path(dir_path))
        escaped_file = e_sh(file_path)
        
        if is_application?
          setup_cmd = %Q{cd #{escaped_dir}; env DYLD_FRAMEWORK_PATH=#{escaped_dir} DYLD_LIBRARY_PATH=#{escaped_dir}}

          # If we have a block, feed it stdout and stderr data
          if block_given? and Xcode.supports_configurations? then
            executable = "./#{file_path}/Contents/MacOS/#{configuration_named(@project.active_configuration_name).product_name}"

            cmd = %Q{#{setup_cmd} #{e_sh executable}}
            block.call(:start, file_path )

            # If the executable doesn't exist, PTY.spawn might not return immediately
						executable_path = File.expand_path(dir_path) + '/' + executable
            if not File.exist?(executable_path)
              block.call(:error, "Executable doesn't exist: #{executable_path}")
              return nil
            end

            stdin, stdout, stderr = Open3.popen3(cmd)
            leftover = { }
            TextMate::IO.exhaust(:output => stdout, :error => stderr) do |str, type|
              # we only want to call ‘block’ with full lines so we cut any trailing bytes that are not newline terminated and save for next time we call block
              if str =~ /\A(.*\n|)([^\n]*)\z/m
                lines = leftover[type].to_s + $1
                leftover[type] = $2
                lines.each { |line| block.call(type, line) }
              else
                raise "Allan’s regexp did not match ‘#{str}’"
              end
            end
            leftover.each_pair { |type, str| block.call(type, str) }

            block.call(:end, 'Process completed.' )
          else
            cmd = "#{setup_cmd} open ./#{escaped_file}"
            %x{#{cmd}}
          end
          
        else
          cmd  = "clear; cd #{escaped_dir}; env DYLD_FRAMEWORK_PATH=#{escaped_dir} DYLD_LIBRARY_PATH=#{escaped_dir} ./#{escaped_file}; echo -ne \\\\n\\\\nPress RETURN to Continue...; read foo;"
          cmd += 'osascript &>/dev/null'
          cmd += " -e 'tell app \"TextMate\" to activate'"
          cmd += " -e 'tell app \"Terminal\" to close first window' &"

          %x{osascript \
            -e 'tell app "Terminal"' \
            -e 'activate' \
            -e #{e_sh "do script \"#{cmd.gsub(/[\\"]/, '\\\\\\0')}\""} \
            -e 'set position of first window to { 100, 100 }' \
            -e 'set custom title of first window to "#{file_path}"' \
            -e 'end tell'
          }
        end
        
      end
    end
  end
  
  class ProjectRunner
    def initialize( projdir )
      @project = Xcode::Project.new(projdir)
    end
    
    def run(&block)
      targets = @project.targets.select { |t| [:application, :tool].include?(t.product_type) }
      case
      when targets.size == 0
        failed(targets, "The project has no immediately executable target to run.")
      when targets.size == 1
        targets.first.run(&block)
      when (targets.size > 1 && ENV['XC_TARGET_NAME'].nil?)
        # multiple runnable targets
        target_name = TextMate::UI.request_item(:title => 'Multiple Targets', :prompt => 'Run which target?', :items => targets.map {|t| t.name})
        unless target_name.nil?
          found_target = targets.find { |t| t.name == target_name }
          found_target.run(&block)
        end
      else
        #info "Will try to run target #{ENV['XC_TARGET_NAME']}"
        found_target = targets.find { |t| t.name == ENV['XC_TARGET_NAME'] }
        if found_target
          found_target.run(&block)
        else
          failed(targets, "No such target: #{ENV['XC_TARGET_NAME']}")
        end
      end
    end
    
    def info(message)
      puts message
    end
    
    def failed(targets, message)
      puts message.chomp + "\n\n"
      targets.each {|t| puts t.inspect }
    end
  end
  
  class HTMLProjectRunner < ProjectRunner
    
    # intercept formatter output to highlight files in the standard file:line:(column:)? format.
    def run(&original_block)
      super do |type, line|
        case type
        when :output, :error
          begin
            type = :HTML
            line = htmlize(line.chomp)
            line = line.gsub(/^(([\w.\/ \+])+):(\d+):((\d+):)?(?!\d+\.\d+)/) do |string|
              # the negative lookahead suffix prevents matching the NSLog time prefix
            
              path        = @project.path_for_basename($1)
              line_number = $3
              column      = $4.nil? ? '' : "&column=#{$5}"
              
              if path != nil and File.exist?(path) then
                %Q{<a href="txmt://open?url=file://#{e_url(path)}&line=#{line_number}#{column}">#{string}</a>}
              else
                string
              end
            end
          rescue Exception => exception
            line = "==> <b>Exception during output formatting:</b> #{exception.class.name}: #{CGI.escapeHTML exception.message.sub(/`(\w+)'/, '‘\1’').sub(/ -- /, ' — ')}\n"
            line << " " + htmlize(exception.backtrace.join("\n "))
            line << "\n\n"
          end
        end
        original_block.call(type, line)
      end
    end
    
    def info(message)
      puts message.gsub(/\n/, '<br>\n')
    end
    
    def failed(targets, message)
      puts message + "\n<ul>"
      targets.each {|t| puts "<li>target:<strong>#{t.name}</strong> product:<strong>#{t.product_path}</strong></li>" }
      puts '</ul>'
    end
  end
end

if __FILE__ == $0
  runner = Xcode::ProjectRunner.new($project_dir)
  runner.run
end
