# Simple interface for reading and writing generic passwords to
# the KeyChain.
module KeyChain
  class << self

    # Adds a generic password to the users keychain using the specified 
    # Account, Service and Password paramaters.
    # Example: security add-generic-password -a "TextMate Bundles" -s "Apache.tmbundle" -p "test-password"     
    def add_generic_password(account, service, pass)
        %x{security add-generic-password -a "#{account}" -s "#{service}" -p "#{pass}"}
    end
    
    # Locates a generic password from the users keychain. 
    def find_generic_password(account, service)
      result = %x{security find-generic-password -g -a "#{account}" -s "#{service}" 2>&1 >/dev/null}
      result =~ /^password: "(.*)"$/ ? $1 : nil
    end
    
  end
end
