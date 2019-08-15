require 'pathname'
require File.dirname(__FILE__) + '/../util/status_codes'

module Subversion
  class UpdateResult
    
    # FIXME 
    # This will fail for non english languages.
    # Not sure how to interpret the svn up output in a language safe way at this point.
    class PlainTextParser
      attr_reader :update_result
      def initialize(base, text)
        verbages = text.scan /(\w+)(?: to)? revision (\d+).$/
        abort "Failed to parse result output: found no verbage lines" if verbages.empty?
        @update_result = UpdateResult.new(base, verbages[0][1], verbages.any? {|v| v[0] == "Updated"})
        text.scan(/^(.)(.)(.)\s\s(.+)$/) do |item_code, property_code, lock_code, relative_path|
          @update_result.add_item(item_code, property_code, lock_code, relative_path)
        end
      end
    end
    
    class Item
      
      attr_reader :item_code, :property_code, :lock_code, :relative_path
      
      def initialize(item_code, property_code, lock_code, relative_path, parent_result)
        @item_code = item_code
        @property_code = property_code
        @lock_code = lock_code
        @relative_path = relative_path
        @parent_result = parent_result
      end
      
      def item_status
        Subversion::StatusCodes.status(@item_code)
      end

      def property_status
        Subversion::StatusCodes.status(@property_code)
      end

      def lock_status
        Subversion::StatusCodes.status(@lock_code)
      end

      def absolute_path
        "#{@parent_result.base}/#{@relative_path}"
      end
      
      def tm_url
        "txmt://open?url=file://" + absolute_path
      end
    end
    
    attr_reader :base, :revision, :items
    attr_accessor :revision
    
    def initialize(base, revision, updates = false)
      @base = Pathname.new(base).realpath
      @revision = revision
      @items = []
      @updates = updates
    end
    
    def add_item(item_code, property_code, lock_code, relative_path)
      @items << Item.new(item_code, property_code, lock_code, relative_path, self)
    end
    
    def updates?
      @updates
    end
    
    def changes?
      not @items.empty?
    end
  end
end

if __FILE__ == $0
  result = Subversion::UpdateResult::PlainTextParser.new("/bin", STDIN.read).update_result
  p result
  result.items.each { |e| puts e.absolute_path }
end