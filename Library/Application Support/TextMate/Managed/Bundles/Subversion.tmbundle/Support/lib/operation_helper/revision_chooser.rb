  require "#{ENV["TM_SUPPORT_PATH"]}/lib/ui"
require "#{File.dirname(__FILE__)}/../subversion.rb"

module Subversion

  class RevisionChooser

    @@nib = "#{File.dirname(__FILE__)}/../../nibs/RevisionSelector.nib"
    def initialize(path)
      @path = path
    end

    def log
      @log ||= Subversion.log(@path, :quiet => true)
    end

    def revision
      r = choose
      r.nil? ? nil : r.first
    end

    def range
      r = choose(true)
      r.nil? ? nil : r.join(':')
    end

    private

    def choose(range = false)
      revcount = (range ? 2 : 1)
      initial_params = {'title' => File.basename(@path), 'entries' => [], 'hideProgressIndicator' => false}
      revision = nil
      TextMate::UI.dialog(:nib => @@nib, :center => true, :parameters => initial_params) do |dialog|
        Thread.new { dialog.parameters = {'entries' => log.ordered_entries, 'hideProgressIndicator' => true} }
        dialog.wait_for_input do |params|
          revision = params['returnArgument']
          button_clicked = params['returnButton']
          if (button_clicked != nil) and (button_clicked == 'Cancel')
            false
          else
            unless revision.length == revcount then
              TextMate::UI.alert(:warning, "Wrong number of revisions selected", "Please select #{revcount} revision#{revcount == 1 ? '' : 's'}")
              true
            else
              false
            end
          end
        end
      end
      revision
    end

  end
end


if __FILE__ == $0
  path = gets.chomp
  chooser = Subversion::RevisionChooser.new(path)
  puts chooser.revision
  puts chooser.range
end