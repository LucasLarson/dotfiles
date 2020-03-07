module Linter
  module_function

  def bash
    settings = [bash_n]
    settings << shellcheck if which("shellcheck")
    settings
  end

  def shellcheck
    {
      name: "ShellCheck",
      version: `'#{which("shellcheck")}' --version`.lines[1].to_s.gsub("version: ", ""),
      output_command: "'#{which("shellcheck")}' --shell=bash --format=gcc",
      line_column_match: /#{filepath}:(\d+):(\d+): /,
      extra_gsubs: {
        /(\[(SC\d+)\])/ =>
          '<a href="javascript:TextMate.system(\'open https://github.com/koalaman/shellcheck/wiki/\2\', null);">\1</a>',
      },
    }
  end

  def bash_n
    /(?<version>\d+\.\d+\.\d+)/ =~ `#{which("bash")} --version`.lines.first
    {
      name: "Bash",
      version: version,
      output_command: "'#{which("bash")}' -n",
      line_match: /bash: line (\d+): /,
    }
  end
end
