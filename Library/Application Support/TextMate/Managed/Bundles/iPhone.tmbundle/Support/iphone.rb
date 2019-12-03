#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"
require 'pp'

class GenerateIPhoneSyntax

  def delete(item)
    @delete_list << item
  end

  def replace_with(item)
    @replace_with_list << item
  end
  def regexpFromFile(filename)
    open(filename).read
  end
  def initialize
    @delete_list = []
    @replace_with_list = []
    file = "#{ENV['TM_BUNDLE_PATH']}/../Objective-C.tmbundle/Syntaxes/Objective-C.tmLanguage"
    io = open(file)
    res = OSX::PropertyList::load(io.read)
    #pp res

    # delete
    delete( {"captures"=> {"1"=>{"name"=>"punctuation.whitespace.support.function.cocoa.leopard"},
    "2"=>{"name"=>"support.function.cocoa.leopard"}},
    })
    delete({"name"=>"support.constant.notification.cocoa.leopard"})
    delete( {"name"=>"support.class.cocoa.leopard"})
    delete( {"name"=>"support.type.cocoa.leopard",})
    delete( {"name"=>"support.constant.cocoa.leopard",})
    delete( {"name"=>"support.class.quartz",})
    delete( {"name"=>"support.type.quartz",})
    # replace_with
    key = regexpFromFile "/tmp/functions.txt"
    replace_with( {"captures"=>  {"1"=>{"name"=>"punctuation.whitespace.support.function.leading.cocoa"},
    "2"=>{"name"=>"support.function.cocoa"}},
    "match"=> "(\\s*)\\b(#{key})\\b"  })
    
    key = regexpFromFile "/tmp/classes.txt"
    replace_with( {"name"=>"support.class.cocoa", "match"=> "\\b#{key}\\b"})
    key = regexpFromFile "/tmp/types.txt"
    replace_with( {"name"=>"support.type.cocoa", "match"=> "\\b#{key}"})
    key = regexpFromFile "/tmp/constants.txt"
    replace_with( {"name"=>"support.constant.cocoa","match"=>"\\b#{key}\\b"})
    key = regexpFromFile "/tmp/notifications.txt"
    replace_with( {"name"=>"support.constant.notification.cocoa", "match"=> "\\b#{key}\\b"})

    kill_list = []
    cap = "captures"
    name = "name"
    res["patterns"].each do |rule|

      @delete_list.each do |item|
        if item.has_key?( cap) && rule.has_key?( cap)

          should_delete = true          
          item[cap].each_key do |number|
            unless rule[cap] == item[cap]
              should_delete = false;
            end
          end
          kill_list << rule if should_delete
        elsif item.has_key?(name) && rule.has_key?(name) && (rule[name] == item[name])
          kill_list << rule
        end
      end

      @replace_with_list.each do |item|
        if item.has_key?(cap) && rule.has_key?(cap)
            if rule[cap] == item[cap]
              # capture 1 is punctuation, 2 is the name
               rule[cap]["2"][name] = item[cap]["2"][name] + ".touch"
              rule["match"] = item["match"]
            end
        elsif item.has_key?(name) && rule.has_key?(name) && (rule[name] == item[name])
          rule[name]= rule[name]  + ".touch"        
          rule["match"] = item["match"]
        end
      end

    end
    res["patterns"] -= kill_list 
    res["name"]="Objective-C (iPhone)"
    res["scopeName"]="source.objc.iPhone"
    res["uuid"] = "B9342863-E48B-4202-B81A-EA4C12A2E0F5"
  #  pp res
    
    open("../Syntaxes/Objective-C (iPhone).tmLanguage","w") do |f|
      f.write res.to_plist
    end
    
  end
end

GenerateIPhoneSyntax.new
  #io = open('|"$DIALOG" -u', "r+")
  #io <<  pl.to_plist
  #io.close_write
  #