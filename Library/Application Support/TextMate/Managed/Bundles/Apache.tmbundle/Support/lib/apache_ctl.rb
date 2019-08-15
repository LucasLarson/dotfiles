# encoding: utf-8

require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/keychain"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview"

BUNDLE_SUPPORT = ENV['TM_BUNDLE_SUPPORT']

TM_DIALOG = e_sh ENV['DIALOG'] unless defined?(TM_DIALOG)
TM_APACHECTL = e_sh(ENV['TM_APACHECTL'] || 'apachectl')

# Ruby Proxy for the Apache HTTP Server Control Interface
# Additionally manages password requests the the user.
#
# Author::    Simon Gregory
class ApacheCTL

    KEYCHAIN_ACCOUNT = "TextMate Bundle"
    KEYCHAIN_SERVICE = "Apache.tmbundle"
    SUDO_FAIL_MESSAGE = /Sorry, try again\.\n/
    
    private
    
    def initialize
        at_exit { finalize() }
    end
    
    # If the user password was gathered during this process, and
    # was successfully used, save it for the next command request.
    def finalize
        finally_save_password() if @save_password_on_success
    end
    
    # Saves the password to the users KeyChain
    def finally_save_password
        KeyChain.add_generic_password( KEYCHAIN_ACCOUNT, KEYCHAIN_SERVICE, self.password )
    end
    
    # Attempts to locate the admin password from the users keychain.
    # When the password is not located a Dialog is generated requesting 
    # the user input the password.
    #
    # Additionally checks to see if the user wants to store the password 
    # in the keychain for future use.
    def fetch_password_from_keychain
        if @password == nil
            @password = KeyChain.find_generic_password(KEYCHAIN_ACCOUNT, KEYCHAIN_SERVICE)
            if @password == nil

                return_hash = request_apache_password()
                #return string is in hash->result->returnArgument.
                #If cancel button was clicked, hash->result is nil.
                @password = return_hash['result']
                @password = @password['returnArgument'] if not @password.nil?

                TextMate.exit_discard if @password == nil
                @save_password_on_success = true if not return_hash['toggleValue'].nil?

            else
                @keychain_password = true
            end
        end
    end
    
    # Launches the Dialog request for the user password.
    def request_apache_password

        params = Hash.new
        params[ "button1" ] = "OK"
        params[ "button2" ] = "Cancel"
        params[ "title"   ] = "Apache Admin Password"
        params[ "prompt"  ] = "Enter password:"
        params[ "string"  ] = ""
        params[ "toggleValue"  ] = "0"
        params[ "toggleTitle"  ] = "Add to Keychain"

        return_plist = %x{#{TM_DIALOG} -cmp #{e_sh params.to_plist} #{e_sh(BUNDLE_SUPPORT+"/nibs/RequestSecureStringKeychain.nib")}}
        return_hash = OSX::PropertyList::load(return_plist)

    end
    
    # Handles all proxy calls to apachectl.
    # When sudo fails  
    def ctl_proxy(cmd, msg='Ok')

      result = `echo "#{self.password}" | sudo -S #{TM_APACHECTL} #{cmd} 2>&1; sudo -k`.sub("Password:\n","")
      result = msg if result.empty?

      if result =~ SUDO_FAIL_MESSAGE
          @save_password_on_success = false;
          if @keychain_password == true
              puts html_head( :window_title => "Apache Bundle",
                              :page_title => "Keychain Password Error.",
                              :sub_title => "* #{cmd} *" );
              puts '<p>Your stored keychain password failed.</p>'
              print '<p>Please use the Kechain Access application to edit or delete your'
              print ' Apache.tmbundle keychain item then run this command again.</p>'
              TextMate.exit_show_html()
          end
          result = "Password failed."
      end

      TextMate.exit_show_tool_tip(result)

    end
    
    public

    # Getters/Setters
    
    # Get the users password.
    # A dialog is used to request the password when it is not
    # found in the users keychain.
    def password
        fetch_password_from_keychain() unless @password
        @password
    end

    # Commands
    
    # Gracefully restarts httpd via apachectl. 
    def graceful
        ctl_proxy('graceful','httpd gracefully restarted')
    end

    # Force restart httpd via apachectl. 
    def restart
        ctl_proxy('restart','httpd restarted')
    end

    # Start httpd via apachectl. 
    def start
        ctl_proxy('start','httpd started')
    end

    # Stop httpd via apachectl. 
    def stop
        ctl_proxy('stop','httpd stopped')
    end

end