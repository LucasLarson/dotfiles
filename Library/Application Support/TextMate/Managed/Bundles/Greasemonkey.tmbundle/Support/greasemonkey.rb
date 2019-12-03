# Greasemonkey bundle commands for TextMate
# By Henrik Nyh <http://henrik.nyh.se>.
# Free to modify and redistribute non-commercially with due credit.


SUPPORT_LIBS = %w{textmate osx/plist escape ui progress}
SUPPORT_LIBS.each {|lib| require "#{ENV['TM_SUPPORT_PATH']}/lib/#{lib}"}

# Set up objects for the GM environment and the current script.
require "#{ENV['TM_BUNDLE_SUPPORT']}/support.rb"
# Code related to Userscripts.org integration.
require "#{ENV['TM_BUNDLE_SUPPORT']}/userscriptsorg.rb"


class Greasemonkey

	# Continues adding @includes or @excludes when hitting the Enter key.
	def continue_header_url
		line_number = ENV["TM_LINE_NUMBER"].to_i-1
		current_line = @script.file_lines[line_number]

		exit unless current_line =~ %r{^(\s*//\s*@(in|ex)clude\s*).*(\n)}  # TextMate always uses \n internally
		print $3 + $1
	end
	

	# For a saved userscript, uploads it to Userscripts.org
	def upload_to_userscripts
		@script.ensure_saved
		@script.ensure_valid
		begin
			UserscriptsOrg::upload(@script)
		rescue Exception => e 
			puts $!
		end
	end


	# For an installed userscript, updates the stored @name, @namespace, @description, @include and @exclude metadata according to the values in the script file. These values are not automatically kept in sync by Greasemonkey. Particularly useful when you've changed @include or @exclude values. Note that changing the @name and @namespace can cause ill effects when re-installing a script, as they are the unique identifier.
	def update_metadata(safe=false)
		@script.ensure_valid
		@script.ensure_installed
		@config.xml do |xml|			
			script = xml.root.elements["Script[@filename='#{@script.file_name}']"]
			script.add_attribute("name", @script.name) unless safe
			script.add_attribute("namespace", @script.namespace) unless safe
			script.add_attribute("description", @script.description)
			script.elements.delete_all("*")
			@script.includes.each {|inc| script.add_element("Include").text = inc }
			@script.excludes.each {|exc| script.add_element("Exclude").text = exc }
		end
		puts "Metadata has been updated."
	end


	# Open any script from a list of installed userscripts.	
	def open_installed_script
		xml = @config.xml		
		scripts = []
		xml.root.elements.to_a('Script').each do |script|
			h = {}
			%w{name filename namespace}.each { |a| h[a] = script.attributes[a] }
			scripts << h
		end
		abort "You do not have any installed scripts to open!" if scripts.empty?

		parameters = {
			# Ascending order of installation
			"listDate" => scripts.reverse,
			# Get these sorted in the same order as Cocoa popup buttons do typeahead find (FIXME: not quite there yet)
			"listAlpha" => scripts.sort_by {|x| x["name"].downcase.split(//).zip(x["name"].swapcase.split(//)) },
			# Load from preferences
			"onlyMine" => Greasemonkey::Preferences[:onlyMine] || 0,
			"byDate" => Greasemonkey::Preferences[:byDate] || 0
		}
		
		in_my_namespace = Proc.new { |s|
			if "#{ENV['TM_NAMESPACE']}".empty? then false else s["namespace"].include?(ENV['TM_NAMESPACE']) end
		}
		%w{Date Alpha}.each { |o| parameters["listMy#{o}"] = parameters["list#{o}"].select &in_my_namespace }
		
		# Flags: modal, centered, parameters
		dialog = `"$DIALOG" -mcp #{e_sh parameters.to_plist} #{e_sh "#{ENV['TM_BUNDLE_SUPPORT']}/nib/OpenInstalledScript.nib"}`
		pl = OSX::PropertyList.load(dialog)
		
		exit unless pl["returnButton"] == "Load"  # Bail if the user cancelled
		
		# Save to preferences
		Greasemonkey::Preferences.merge!(pl, :keep => %w{onlyMine byDate})

		source_base = "#{ "My" if pl["onlyMine"]==1 }#{ pl["byDate"]==1 ? "Date" : "Alpha" }"
		source = pl["list#{source_base}"]
		index = pl["selected#{source_base}"] || 0			

		exit if source.empty?
		script = source[index]		
		path = "#{@config.directory}/#{script["filename"]}"
		TextMate.go_to(:file => path)
	end
	

	# Inverts the cosmos.
	def reload_firefox(time=nil)
		`osascript <<'END'
			tell app "Firefox" to activate
			tell app "System Events"
				if UI elements enabled then
					keystroke "r" using command down
					-- Fails if System Preferences > Universal access > "Enable access for assistive devices" is not on 
				else
					tell app "Firefox" to Get URL "javascript:location.reload();" inside window 1
					-- Fails if Firefox is set to open URLs from external apps in new tabs.
				end if
			end tell
			#{%{
				delay #{time.to_i}
				tell app "TextMate" to activate
			} if time}
END`
	end


	# For an installed userscript, uninstalls it and closes the document.	
	def uninstall_script
		@script.ensure_installed

		xml = @config.xml
		xml.root.elements.delete("Script[@filename='#{@script.file_name}']")

		button = TextMate::UI.alert(:warning, %Q{Uninstall "#{@script.name}"?}, "The file will be moved to the Trash folder.", "Uninstall", "Cancel")
		exit if button == "Cancel"
		
		@config.xml = xml  # Save XML if we're still around

		# Move the script file to trash
		`mv #{e_sh @script.file_path} #{e_sh "#{ENV["HOME"]}/.Trash"}`

		# Close the document
		`osascript <<'END'
			tell application "TextMate" to set isUnsaved to modified of document 1
			tell application "System Events"
				#{AppleScript.ensure_gui_scripting("The script was uninstalled, but the window could not be closed.")}
				keystroke "w" using command down -- close tab
				if isUnsaved then keystroke "d" using command down -- don't save
			end tell
END`	
	end


	# For an installed userscript, opens up "about:config" in Firefox and filters it to the GM_get/setValue() values for that script.	
	def manage_gm_values
		@script.ensure_installed
		key = "greasemonkey.scriptvals.#{@script.xml_namespace}/#{@script.xml_name}"
		key.sub!(/.*~/, '')  # Work around weird bug where "~" is output as "a"...

		`osascript <<'END'
			tell application "System Events" to set firefoxIsRunning to (name of processes) contains "firefox-bin"

			tell application "Firefox"
				activate
				if not firefoxIsRunning then delay 2
				Get URL "about:config" inside window 1
			end tell

			tell application "System Events"
				#{AppleScript.ensure_gui_scripting("Could not filter.")}
				delay 2
				(keystroke "#{key}")
			end tell
END`
	end


	# Installs the current document as a Greasemonkey userscript, and starts editing the installed file instead.	
	def install_and_edit
		@script.avoid_installed
		@script.ensure_valid
		
		# Make an initial choice of filename
		filename = @script.name.gsub(/\W/, '')[0,24].downcase + ".user.js"
		
		# Is a script already installed with this name+namespace?
		xml = @config.xml
		
		same_script = xml.root.elements["Script[@name='#{@script.name}'][@namespace='#{@script.namespace}']"]
		
		if same_script  # Overwrite, reusing that filename
			filename = same_script.attributes["filename"]
		else  # Make sure we don't overwrite anything
			while @config.file_lines.any? {|line| line =~ /filename='#{filename}'/ }  # filename is being used
				filename.sub!(/(.)\.user\.js$/) { "#{$1.to_i+1}.user.js" }  # increment it
			end
		end
		
		# Create script
		new_script_file_name = "#{@config.directory}/#{filename}"
		File.open(new_script_file_name, "w") {|file| file.print @script.file_data}
		
		# Update config
		xml.root.delete same_script if same_script

		new_script = xml.root.add_element "Script",
			{"name" => @script.name,
			 "namespace" => @script.namespace,
			 "filename" => filename,
			 "description" => @script.description,
			 "enabled" => "true"}

		@script.includes.each {|inc| new_script.add_element("Include").text = inc }
		@script.excludes.each {|exc| new_script.add_element("Exclude").text = exc }
		@config.xml = xml
		
		# Close old file and open the new one.
		# This is done in a detached process to survive the closing of the file.
		`{
		osascript <<'END'
			tell app "TextMate"
				activate
				set isUnsaved to modified of document 1
				tell application "System Events"
					#{AppleScript.ensure_gui_scripting("The script was installed and will be opened, but the old document could not be closed.")}
					keystroke "w" using command down -- close tab
					if isUnsaved then keystroke "d" using command down -- don't save
				end tell
			end tell
END
		open -a TextMate #{e_sh new_script_file_name}
		} &>/dev/null &`
		
	end

	RE_LOG = %r{(^|[\s;])(//)?(\s*(GM_|(unsafeWindow\.)?console\.)log\(.*\);?\s*)}

	# In selection or entire document, comment out all log statements if any were uncommented; otherwise uncomment all.
	def toggle_log_comments
		any_uncommented_logs = @script.file_lines.any? { |line| line =~ RE_LOG and $2.nil? }
		@script.file_lines.each do |line|
			line.sub!(RE_LOG) { "#$1#{ "//" if any_uncommented_logs }#$3" }
			print line
		end
	end


	# In selection or entire document, remove all log statements.
	def remove_logs
		@script.file_lines.each do |line|
			if line.sub!(RE_LOG, '\1')
				print line unless line.strip.empty?
			else
				print line
			end
		end
	end

end
