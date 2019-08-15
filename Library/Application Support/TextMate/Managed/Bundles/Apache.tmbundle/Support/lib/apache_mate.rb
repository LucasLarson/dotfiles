#!/usr/bin/env ruby18 -wKU

require "rexml/document"

#Locates the ServerRoot path.
def find_server_root
    conf = File.open( ENV['TM_FILEPATH'], "r" )
    conf.each do |line|
        if line =~ /^ServerRoot/ 
            return line.sub( "ServerRoot \"", "").sub("\"\n","")
        end
    end
    return ""
end

# Generates a completion list based on the prescribed document.
#
# TODO: Automatically locate modules and directives
#       /Library/WebServer/share/httpd/manual/mod/directives.html       
# TODO: Update the xPath definition to use the directives.html.
#
# Example useage: generate_definition_completions( "directive_list.xml" )
#
def generate_definition_completions( directive_list )

    completions = "{ completions = ( "
    
    directive_doc = REXML::Document.new File.new(directive_list)
    
    directive_doc.elements.each( "ul/li/a" ) do |tag|
        completion = tag[0].to_s.sub("&lt;","").sub("&gt;","");
        completions += "'" + completion + "',"
    end
        
    completions = completions.chop + " ); }"
    print completions
    
end

# TODO: generate_module_completions
# /Library/WebServer/share/httpd/manual/mod/index.html
#def generateModuleCompletions( module_list )
#end
