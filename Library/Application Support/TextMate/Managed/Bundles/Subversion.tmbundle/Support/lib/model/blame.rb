require "rexml/document"
require 'time'

module Subversion

  class Blame
    attr_reader :paths

    def initialize(paths = [])
      @paths = paths
    end

    class XmlParser
      def initialize(xml,content, logs)
        @paths = []
        @content_lines = {}
        @logs = logs
        content.each { |k,v| @content_lines[k] = v.split("\n") }
        REXML::Document.parse_stream(xml, self)
      end

      def xmldecl(*ignored)
      end

      def tag_start(name, attributes)
        case name
        when 'target'
          @path = Path.new(attributes['path'], @logs[attributes['path']])
        when 'entry'
          @line_num = attributes['line-number'].to_i
        when 'commit'
          @revision = attributes['revision'].to_i
        end
      end

      def tag_end(name)
        case name
        when 'author'
          @author = @text
        when 'date'
          @date = Time.xmlschema(@text)
        when 'entry'
          @path.lines[@line_num] = Path::Line.new(@revision, @author, @date, @content_lines[@path.path][(@line_num - 1)])
        when 'target'
          @paths << @path
        end
      end

      def text(text)
        @text = text
      end

      def blame
        Subversion::Blame.new(@paths)
      end
    end

    class Path
      class Line
        attr_reader :revision,:author,:date,:content
        def initialize(revision,author,date,content)
          @revision = revision
          @author = author
          @date = date
          @content = content
        end
      end
      attr_reader :path, :lines, :log
      def initialize(path, log)
        @path = path
        @log = log
        @lines = {}
      end
    end

  end
end