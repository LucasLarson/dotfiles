#!/usr/bin/env ruby18

require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'

circuitPath = ENV['TM_SELECTED_FILE']

if not circuitPath then
	print "Please select a folder or a file in whose folder you want to create the circuit"
	exit(206)
end

openSwitch = false
circuitDir = ""

# If it isn't a directory, get the directory name
if not test(?d, circuitPath) then
	circuitPath = File.dirname(circuitPath)
end

# Ask for the circuit name
result = TextMate::UI.request_string :title => "New Circuit", :prompt => "Enter the circuit name:"

if result.readline.chomp == "1" then  # OK clicked
	circuitName = result.readline.chomp
	result.close
	
	# Make sure the circuit doesn't exist yet
	circuitDir = "#{circuitPath}/#{circuitName}"

	if test(?d, "#{circuitDir}") then
		TextMate::UI.alert(:warning, "Error", "That directory already exists.", 'OK')
		exit(200)
	end

	# Ask for optional circuit files
	cmd = <<-CMD
		tell application "SystemUIServer"
			activate
			choose from list {"fbx_settings", "fbx_layouts"} with title "New Circuit" with prompt "Select optional circuit elements:" with multiple selections allowed and empty selection allowed
	end tell
	CMD
	
	result = IO.popen("osascript <<'AS'\n#{cmd}AS")
	optionalFiles = result.readline.chomp
	result.close
	
	if optionalFiles != "false" then
		optionalFiles = optionalFiles.split(/,\s*/)

		# Make the circuit directory and copy the switch
		supportDir = ENV['TM_BUNDLE_SUPPORT'] + "/circuit"
		system("mkdir '#{circuitDir}'")
		system("cp '#{supportDir}/fbx_switch.a4d' '#{circuitDir}'")
	end

	for f in optionalFiles
		system("cp '#{supportDir}/#{f}.a4d' '#{circuitDir}'")
	end

	# Now search up to the project root, looking for fbx_circuits.a4d
	curDir = circuitDir
	projectDir = ENV['TM_PROJECT_DIRECTORY']
	found = 0

	until curDir == projectDir
		if test(?f, "#{curDir}/fbx_circuits.a4d") then
			found = 1
			break
		else
			# Go up one directory
			curDir = File.dirname(curDir)
		end
	end

	if found == 1 then
		# Calculate the root-relative path to the target circuit
		circuitPath = circuitDir.slice(curDir.length + 1..circuitDir.length)
		
		# First find the name of the root circuit
		circuits = "#{curDir}/fbx_circuits.a4d"
		result = IO.popen(%Q{egrep '^[[:space:]]*\\$fusebox\{"circuits"\}\{"(home|root)"\}' "#{circuits}"})

		if not result.eof? then
			res = result.readline
		else
			res = ""
		end

		result.close

		if res.length > 0 then
			# Extract the root circuit name
			res.match(/^\s*\$fusebox\{"circuits"\}\{"(home|root)"\}/)
			root = $1

			# Now look for the current ciruit
			result = IO.popen(%Q{egrep -c '^[[:space:]]*\\$fusebox\{"circuits"\}\{"#{circuitName}"\}' "#{circuits}"})
			res = result.readline.chomp
			result.close

			if res == "0" then
				sedCmd = <<-SED
					sed -E '
					/^([[:space:]]*)%>/i\\
					$fusebox{"circuits"}{"#{circuitName}"} := "#{root}/#{circuitPath}"
					' '#{circuits}'
				SED

				result = IO.popen("#{sedCmd}")
				newCircuits = result.readlines
				result.close
				
				f = open(circuits, "w")
				f.write(newCircuits)
				f.close
				
				openSwitch = true
			end
		end
	end
end

if openSwitch
	system("mate '#{circuitDir}/fbx_switch.a4d' &>/dev/null &")
else
	system(%Q{osascript -e 'tell app "TextMate" to activate' &>/dev/null &})
end