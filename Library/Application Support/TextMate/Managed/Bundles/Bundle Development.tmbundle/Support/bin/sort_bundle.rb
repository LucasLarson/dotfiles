#!/usr/bin/env ruby18 -wKU

$: << '/Applications/TextMate.app/Contents/SharedSupport/Support/lib/'
$: << '/Library/Application Support/TextMate/Support/lib/'
$: << '~/Library/Application Support/TextMate/Support/lib/'
require 'escape'
require 'osx/plist'

BundleDir = Dir.pwd + '/'

unless File.exist?(BundleDir + 'info.plist')
  puts 'info.plist not found run this script from a bundle directory'
  exit
end

def get_item_uid(item, extension)
  separator_file = BundleDir + item + '/separator.' + extension
  uid = false
  if File.exists?(separator_file)
    uid = OSX::PropertyList::load(File.read(separator_file))['uuid']
  else
    uid = (0..5).map{(0..5).map{rand(15).to_s(16) }.to_s.upcase}.join('-')
    File.open(BundleDir + item + '/separator.' + extension, 'w') do |separator|
      separator << <<-HTML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>name</key>
        <string>#{item.center(25, '=')}</string>
        <key>uuid</key>
        <string>#{uid}</string>
      </dict>
      </plist>
      HTML
    end
  end
  uid
end

order = []
# 'Templates' => 'tmTemplate', 
{'Preferences' => 'tmPreferences', 'Syntaxes' => 'tmLanguage', 'Snippets' => 'tmSnippet', 'Commands' => 'tmCommand', 'DragCommands' => 'tmDragCommand', 'Macros' => 'tmMacro'}.each do |(item, extension)|
  next unless File.exists?(BundleDir + item)
  puts item
  uuid = get_item_uid(item, extension)
  order.delete(uuid)
  order << uuid
  order += `grep -ho '[A-Z0-9]\\+-\\([A-Z0-9]\\+-\\?\\)\\{5,\\}' #{e_sh(BundleDir + item)}/*`.split("\n")
end
order.uniq!
info = OSX::PropertyList::load(File.read(BundleDir + 'info.plist'))
info['ordering'] = order
File.open(BundleDir + 'info.plist', 'w') do |info_file|
  info_file << info.to_plist
end
`osascript -e 'tell app "TextMate" to reload bundles'`