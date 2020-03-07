module Linter
  module_function

  def json
    if which("jsonlint")
      jsonlint
    else
      ruby_json
    end
  end

  def ruby_json
    /(?<version>\d+\.\d+\.\d+(p\d+)?)/ =~ `#{which("ruby")} --version`
    {
      name: "Ruby (JSON module)",
      version: version,
      output_command: "'#{which("ruby")}' -rjson -e'begin JSON.parse(IO.read(ARGV.first)); rescue => e; puts e; end' test.json",
    }
  end

  def jsonlint
    {
      name: "JSONLint",
      version: `'#{which("jsonlint")}' --version`,
      output_command: "'#{which("jsonlint")}' --compact --quiet",
      line_column_match: /#{filepath}: line (\d+), col (\d+), /,
    }
  end
end
