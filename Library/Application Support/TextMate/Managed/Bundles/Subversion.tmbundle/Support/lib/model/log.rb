require "rexml/document"
require 'time'

module Subversion

  class Log

    attr_reader :entries

    def initialize(entries)
      @entries = entries
    end
    
    def ordered_entries
      @entries.values.sort! {|x,y| y.rev <=> x.rev }
    end 
    
    def revisions
      @entries.keys.sort!
    end

    class Entry < Hash
      def msg
        self['msg']
      end
      def msg=(msg)
        self['msg'] = msg
      end
      def rev
        self['rev']
      end
      def rev=(rev)
        self['rev'] = rev
      end
      def date
        self['date']
      end
      def date=(date)
        self['date'] = date
      end
      def author 
        self['author']
      end
      def author=(author)
        self['author'] = author
      end
      def paths
        self['paths']
      end
      def paths=(paths)
        self['paths'] = paths
      end
    end

    class XmlParser
      def initialize(xml)
        @entries = {}
        REXML::Document.parse_stream(xml, self)
      end

      def xmldecl(*ignored)
      end

      def tag_start(name, attributes)
        case name
        when 'logentry'
          @current_entry = Entry.new
          @current_entry.rev = attributes['revision'].to_i
          @current_entry.paths = {}
        when 'path'
          @current_action = attributes['action']
        end
      end

      def tag_end(name)
        case name
        when 'author','msg'
          @current_entry[name] = @tag_text
        when 'date'
          @current_entry[name] = Time.xmlschema(@tag_text)
        when 'logentry'
          @entries[@current_entry.rev] = @current_entry
        when 'path'
          @current_entry.paths[@tag_text] = @current_action
        end
      end

      def text(text)
        @tag_text = text
      end

      def log
        Log.new(@entries)
      end
    end

  end
end

if __FILE__ == $0
  log = Subversion::XmlLogParser.new(STDIN.read).log
  puts "revisions: #{log.revisions.join(',')}"
  p log
end