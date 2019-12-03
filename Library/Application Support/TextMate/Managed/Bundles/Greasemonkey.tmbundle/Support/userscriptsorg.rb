# encoding: utf-8

# Greasemonkey Userscript.org integration for TextMate
# By Henrik Nyh <http://henrik.nyh.se>.
# Free to modify and redistribute non-commercially with due credit.

require "webrick"
require "rexml/document"
require "#{ENV['TM_BUNDLE_SUPPORT']}/levenshtein"

	
class Hash
	def to_query_string
    	esc = WEBrick::HTTPUtils.method(:escape_form)
    	map { |k, v| esc.call(k.to_s) + "=" + esc.call(v.to_s) }.join("&")
	end
end

class Struct
 		def to_hash
		members.zip(values).inject({ }) {|hash, (key, value)|  hash.merge(key => value) }
	end
end

class UserscriptsOrg
	COOKIE_JAR = "/tmp/gmbundle_#{ENV["USER"]}.cookiejar"

	LOGIN_NIB = "#{ENV['TM_BUNDLE_SUPPORT']}/nib/UsoLogin.nib"
	RESOLVE_NIB = "#{ENV['TM_BUNDLE_SUPPORT']}/nib/UsoResolve.nib"

	BASE_URL = "http://userscripts.org"
	LOGIN_URL = "#{BASE_URL}/sessions"
	POST_URL = "#{BASE_URL}/scripts/create"
	UPDATE_URL = "#{BASE_URL}/scripts/update_src"
	SCRIPTS_URL = "#{BASE_URL}/users/me.xml;scripts"
	MANUAL_URL = "#{BASE_URL}/scripts/new"
	
	PROGRESS_DIALOG_TITLE = "Upload to Userscripts.org"


	RemoteScript = Struct.new(:identifier, :name, :description)
	

	def self.upload(script)
		return false unless self.authenticate

		if remote_scripts.empty?  # or (eponymous_scripts.empty? and SCRIPTET NYARE ÄN NYASTE REMOTEFILEN)
			# This is the user's first script, so add without asking
			self.upload_script(script)
		elsif eponymous_scripts_to(script).size == 1
			# The script name is uniquely present on US.O, so update it without asking
			self.upload_script(script, eponymous_scripts_to(script).first)
		else
			# No script names match, or multiple script names match - should be added OR updated
			self.disambiguate(remote_scripts, script)
		end
		
	end
	
	def self.authenticate
		properties = {}
		# Get e-mail from preferences or else from the address book "me" card
		properties["login"] = Greasemonkey::Preferences[:login] || OSX::PropertyList.load(`defaults read AddressBookMe`)["ExistingEmailAddress"] rescue ""
		properties["password"] = Greasemonkey::Preferences[:password] || ""
		
		response_code = nil
		TextMate.call_with_progress(:title => PROGRESS_DIALOG_TITLE, :message => "Authenticating…") do
			response_code = `curl -d "#{properties.to_query_string}" --cookie-jar "#{COOKIE_JAR}" "#{LOGIN_URL}" -o /dev/null --write-out "%{http_code}" 2> /dev/null`.to_i
		end
		
		case response_code
		when 200
			#  Not logged in - prompt
			self.present_prompt(properties)
		when 302
			# Logged in successfully
			return true
		else
			raise "Unexpected problem logging into Userscripts.org! Connection could be offline."
		end	
	end
	
	protected
	def self.present_prompt(properties, retrying=false)
		raw_response = `"$DIALOG" -cmp #{e_sh(properties.to_plist)} "#{LOGIN_NIB}"`
		properties = OSX::PropertyList.load(raw_response)

		return false unless properties["returnButton"]=="Connect"

		Greasemonkey::Preferences.merge!(properties, :keep => %w{login password})

		self.authenticate
	end
	
	def self.remote_scripts
		return @remote_scripts if @remote_scripts
		xml = nil
		TextMate.call_with_progress(
			:title => PROGRESS_DIALOG_TITLE,
			:message => "Retrieving remote scripts…"
		) do
			xml = `curl --cookie "#{COOKIE_JAR}" --location "#{SCRIPTS_URL}"  2> /dev/null`
		end
		# TODO: Handle failure - also handle lost connection, blabla
		xml = REXML::Document.new xml
		raise "Could not retrieve list of remote scripts!" unless xml.root

		scripts = []
		xml.root.elements.to_a('script').each do |script|
			scripts << RemoteScript.new(
				script.elements["id"].text.to_i,
				script.elements["name"].text,
				if (sum = script.elements["summary"] and sum.text) then sum.text else script.elements["description"].text end
			)
		end
		@remote_scripts = scripts
	end
	
	def self.eponymous_scripts_to(script)
		return @eponymous_scripts if @eponymous_scripts
		@eponymous_scripts = remote_scripts.select {|remote| remote.name == script.name}  # FIXME
	end
	
	def self.upload_script(script, old_script=nil)	
		response_code = url = nil
		TextMate.call_with_progress(
			:title => PROGRESS_DIALOG_TITLE,
			:message => (if old_script then "Updating script…" else "Uploading as new script…" end)
		) do
			response_code, url = `curl -H "Expect:" -F "file[src]=@#{script.file_path}" --cookie "#{COOKIE_JAR}" --o /dev/null --location "#{if old_script then "#{UPDATE_URL}/#{old_script.identifier}" else POST_URL end}" --write-out "%{http_code}\t%{url_effective}"  2> /dev/null`.split("\t")
			# -H "Expect:" is a lighttpd workaround, http://curl.haxx.se/mail/archive-2005-11/0134.html
		end
		response_code = response_code.to_i
		
		if response_code == 200 and url =~ /\d+\/?$/  # The URL should end with a numerical id if everything worked
			`open "#{url}"`
		else
			raise "Unexpected error uploading script!"
		end
	end
	
	def self.disambiguate(among_scripts, script)
		# Sort remote script names by edit distance to local script name
		among_scripts.sort! {|a,b| Levenshtein::distance(a.name, script.name) <=> Levenshtein::distance(b.name, script.name)}
		
		scripts = among_scripts.map {|s| s.to_hash}
		
		update_selected = if eponymous_scripts_to(script).empty? then 0 else 1 end 
		
		properties = {"scripts" => scripts, "updateSelected" => update_selected}
		raw_response = `"$DIALOG" -cmp #{e_sh(properties.to_plist)} "#{RESOLVE_NIB}"`
		result = OSX::PropertyList.load(raw_response)["result"]
		
		return false unless result
		
		if result["updateSelected"]==1
			old_script = among_scripts.find {|s| s.identifier == result["returnArgument"]}
			upload_script(script, old_script)
		else  # New script
			upload_script(script)
		end
		
	end
	
end