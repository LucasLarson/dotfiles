require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/process"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/checkout_result_html"


start = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || ENV['HOME']
if url = TextMate::UI.request_string(:prompt => "Enter Repository URL:", :title => "svn checkout")
  if base = TextMate::UI.request_file(:title => "Select Checkout Directory", :only_directories => true, :directory => start)
    result = Subversion.checkout(base.first, url)
    view = Subversion::CheckoutResult::HTMLView.new(result)
    view.render
    TextMate::Process.run(ENV['TM_MATE'], base)
    TextMate.exit_show_html
  end
end

TextMate.exit_discard