require ENV['TM_SUPPORT_PATH'] + '/lib/escape.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'

class Marker
  attr_reader :name, :regexp, :color
  def initialize(options = { })
    @name      = options['name'] || 'untitled'
    @color     = options['color']
    @has_color = !options['no_color']
    @trim      = !!options['trim']
    @disabled  = !!options['disabled']

    if options['pattern'] =~ %r{\A/(.*)/([imx]*)\z}
      transform = {
        'i' => Regexp::IGNORECASE,
        'x' => Regexp::EXTENDED,
        'm' => Regexp::MULTILINE,
      }
      ptrn, flags = $1, $2.split(//)
      f = flags.inject(0) { |flags, letter| flags += transform[letter] if transform.has_key? letter }
      @regexp = Regexp.new(ptrn, f)
    else
      raise "Invalid regular expression: #{options['pattern']}"
    end
  end

  def has_color?
    @has_color
  end

  def disabled?
    @disabled
  end

  def trim?
    @trim
  end
end

class Settings
  @defaults = [
    { 'name'    => 'FIXME',
      'pattern' => '/FIX ?ME[\s,:]+(\S.*)$/i',
      'color'   => '#A00000',
    },
    { 'name'    => 'TODO',
      'pattern' => '/TODO[\s,:]+(\S.*)$/i',
      'color'   => '#CF830D',
    },
    { 'name'    => 'CHANGED',
      'pattern' => '/CHANGED[\s,:]+(\S.*)$/',
      'color'   => '#008000',
    },
    { 'name'    => 'RADAR',
      'pattern' => '/(.*<)ra?dar:\/(?:\/problem|)\/([&0-9]+)(>.*)$/',
      'color'   => '#0090C8',
      'trim'    => true,
    },
  ]
  
  def self.markers
    plist = open(ENV['HOME'] + "/Library/Preferences/#{ENV['TM_APP_IDENTIFIER'] || 'com.macromates.textmate'}.plist") { |io| OSX::PropertyList.load(io) }
    res = plist['TODO Markers'] || @defaults
    res.map { |e| Marker.new(e) }.reject { |e| e.disabled? }
  end

  def self.show_ui
    defaults = { 'TODO Markers' => @defaults }
    dynamicClasses = {
      'TODO_NewMarker' => {
        'name'     => 'MY MARKER',
        'pattern'  => '/marker:/i',
        'no_color' => true,
      }
    }

    %x{ "$DIALOG" \
          -d #{e_sh defaults.to_plist} \
          -n #{e_sh dynamicClasses.to_plist} \
          -q Preferences
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  STDOUT.reopen('/dev/console')
  STDERR.reopen('/dev/console')
  Process.detach(Process.fork { Settings.show_ui })
end
