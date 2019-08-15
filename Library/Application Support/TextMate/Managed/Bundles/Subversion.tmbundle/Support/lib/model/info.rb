require "rexml/document"
require 'time'

module Subversion

  class Info
    attr_reader :entries

    def initialize(entries = [])
      @entries = entries
    end

    class XmlParser
      def initialize(xml)
        @entries = []
        REXML::Document.parse_stream(xml, self)
      end

      def xmldecl(*ignored)
      end

      def tag_start(name, attributes)
        case name
        when 'entry'
          @entry = Entry.new
          @entry.kind = attributes['kind']
          @entry.path = attributes['path']
          @entry.revision = attributes['revision']
        when 'repository'
          @repository = Entry::Repository.new
        when 'wc-info'
          @wc_info = Entry::WorkingCopyInfo.new
        when 'commit'
          @commit = Entry::Commit.new
          @commit.revision = attributes['revision']
        end
      end

      def tag_end(name)
        case name
        when 'url'
          @entry.url = @text
        when 'root'
          @repository.root = @text
        when 'uuid'
          @repository.uuid = @text
        when 'repository'
          @entry.repository = @repository
        when 'schedule'
          @wc_info.schedule = @text
        when 'text-updated'
          @wc_info.text_updated = Time.xmlschema(@text)
        when 'checksum'
          @wc_info.checksum = @text
        when 'wc-info'
          @entry.wc_info = @wc_info
        when'author'
          @commit.author = @text
        when 'date'
          @commit.date = Time.xmlschema(@text)
        when 'commit'
          @entry.commit = @commit
        when 'entry'
          @entries << @entry
        end
      end

      def text(text)
        @text = text
      end

      def info
        Subversion::Info.new(@entries)
      end
    end


    class Entry
      attr_accessor :path, :kind, :revision, :url, :repository, :wc_info, :commit

      class WorkingCopyInfo
        attr_accessor :schedule, :copy_from_url, :copy_from_rev, :text_updated, :prop_updated, :checksum
        # TODO support conflict info
      end

      class Repository
        attr_accessor :root, :uuid
      end

      class Commit
        attr_accessor :revision, :author, :date
      end
    end

  end
end

if __FILE__ == $0
  p Subversion::Info::XmlParser.new(STDIN.read).info
end