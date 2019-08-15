require 'pathname'
require File.dirname(__FILE__) + '/../util/status_codes'

module Subversion
  class CheckoutResult
    
    # FIXME 
    # This will fail for non english languages.
    class PlainTextParser
      attr_reader :checkout_result
      def initialize(base, text)
        lines = text.split("\n")
        abort "Unable to determine checkout revision" unless lines.pop =~ /revision (\d+).$/
        @checkout_result = CheckoutResult.new(base, $1)
        lines.each do |line|
          line.scan /^(.)(.)(.)\s\s(.+)$/ do |item_code, property_code, lock_code, relative_path|
            @checkout_result.add_item(item_code, property_code, lock_code, relative_path)
          end
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
    
    def initialize(base, revision)
      @base = Pathname.new(base).realpath
      @revision = revision
      @items = []
    end
    
    def add_item(item_code, property_code, lock_code, relative_path)
      @items << Item.new(item_code, property_code, lock_code, relative_path, self)
    end

  end
end

if __FILE__ == $0
  result = Subversion::CheckoutResult::PlainTextParser.new("/bin", STDIN.read).checkout_result
  p result
  # result.items.each { |e| puts e.absolute_path }
end