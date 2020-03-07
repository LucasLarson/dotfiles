module Linter
  module_function

  def ruby
    settings = [ruby_wc]
    settings << rubocop if which("rubocop")
    settings
  end

  def ruby_wc
    /(?<version>\d+\.\d+\.\d+(p\d+)?)/ =~ `#{which("ruby")} --version`
    {
      name: "Ruby",
      version: version,
      output_command: "'#{which("ruby")}' -wc",
      line_match: /#{filepath}:(\d+):/,
      extra_gsubs: {
        "Syntax OK" => "",
      },
    }
  end

  def rubocop
    fix = " --auto-correct" if setting?(:fix_on_save)
    rubocop_type_regex = %r{([WC]:)( \[Corrected\])? (\w+)/(\w+)}
    rubocop_docs_lambda = lambda do |match|
      rubocop_type_regex =~ match
      _, type, corrected, category, check = Regexp.last_match.to_a
      category_down = category.downcase
      check_down = check.downcase
      url = "https://rubocop.readthedocs.io/en/latest/cops_#{category_down}/##{category_down}#{check_down}"
      href = "javascript:TextMate.system('open #{url}', null);"
      "#{type}#{corrected} <a href=\"#{href}\">#{category}/#{check}</a>"
    end
    {
      name: "RuboCop",
      version: `'#{which("rubocop")}' --version`,
      output_command: "'#{which("rubocop")}' --format=emacs --display-cop-names#{fix}",
      line_column_match: /#{filepath}:(\d+):(\d+): /,
      extra_gsubs: {
        rubocop_type_regex => rubocop_docs_lambda,
        "C: " => "convention: ",
        "W: " => "warning: ",
      },
    }
  end
end
