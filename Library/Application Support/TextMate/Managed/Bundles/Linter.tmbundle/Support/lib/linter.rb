require "#{ENV["TM_SUPPORT_PATH"]}/lib/textmate"
ENV["PATH"] += ":#{ENV["TM_BUNDLE_SUPPORT"]}/bin"
$LOAD_PATH << "#{ENV["TM_BUNDLE_SUPPORT"]}/lib"

module Linter
  module_function

  def tm_scope
    ENV["TM_SCOPE"].to_s
  end

  def tm_scopes
    tm_scope.split(" ")
  end

  def setting?(key)
    tm_scopes.include?("bundle.linter.#{key.to_s.tr("_", "-")}")
  end

  def strip_trailing_whitespace!(write: true)
    return if filepath.empty?

    end_string = "__END__\n".freeze
    seen_end = false
    whitespace_regex = /[\t ]+$/
    empty_string = "".freeze
    @stdin_lines ||= STDIN.read.lines
    @stdin_lines.map! do |line|
      if seen_end || line == end_string
        seen_end ||= true
        line
      else
        line.gsub(whitespace_regex, empty_string)
      end
    end
    return unless write
    IO.write(filepath, @stdin_lines.join)
  end

  def ensure_trailing_newline!
    return if filepath.empty?

    @stdin_lines ||= STDIN.read.lines
    last_char = @stdin_lines.last.to_s.chars.last
    newline = "\n".freeze
    @stdin_lines << newline if last_char != newline
    IO.write(filepath, @stdin_lines.join)
  end

  def lint_strip_ensure_on_save
    if setting?(:strip_whitespace_on_save)
      if setting?(:ensure_newline_on_save)
        strip_trailing_whitespace!(write: false)
        ensure_trailing_newline!
      else
        strip_trailing_whitespace!
      end
    elsif setting?(:ensure_newline_on_save)
      ensure_trailing_newline!
    end

    lint(manually_requested: false) if setting?(:lint_on_save)
  end

  def lint(manually_requested: true)
    return if filepath.empty?

    language_found = false
    language_selectors = {
      bash: { select: /source\.shell/ },
      json: { select: /source\.json/ },
      markdown: { select: /text\.html\.markdown/ },
      ruby: {
        select: /source\.ruby/,
        reject: /(source\.ruby\.embedded(\.haml)?|text\.html\.(erb|ruby))/,
      },
    }
    language_selectors.each do |language, match|
      next if (reject = match[:reject]) && tm_scope =~ reject
      next unless tm_scope =~ match[:select]
      language_found ||= true

      require "languages/#{language}"
      output(send(language))
    end

    return if language_found
    return unless manually_requested

    first_scope = tm_scopes.first
    puts "Error: no Linter found for #{first_scope}! Please consider submitting a pull request to https://github.com/MikeMcQuaid/Linter.tmbundle to add one."
  end

  def filepath
    ENV["TM_FILEPATH"].to_s
  end

  def filename
    return "" if filepath.empty?
    File.basename(filepath)
  end

  def which(name)
    @which_cache ||= {}
    @which_cache.fetch(name) do
      env = name.upcase.tr("-", "_")
      name = ENV["LINTER_#{env}"] || ENV[env] || name
      which = `which '#{name}'`.chomp
      next if which.empty?
      which
    end
  end

  def output(all_settings)
    all_settings = [all_settings].flatten

    file_link = "<a href='txmt://open/?url=file://#{filepath}'>#{filename}</a>"

    names_versions = []
    all_settings.each do |settings|
      name = settings[:name]
      version = settings[:version].to_s.chomp
      name_version =
        if version.empty?
          settings[:name]
        else
          "#{name} #{version}"
        end
      names_versions << name_version
    end
    names_versions = names_versions.join(", ")
    puts "Linting #{file_link} with #{names_versions}<pre style='word-wrap: break-word;'>"

    output_something = false
    all_settings.each do |settings|
      output = settings[:output]
      output ||= begin
        output_command = settings[:output_command]
        unless output_command.include?(filepath)
          output_command += " '#{filepath}'"
        end
        env = settings[:output_command_env]
        if env
          old_env = {}
          env.each do |key, value|
            key = key.to_s
            old_env[key] = ENV.delete(key)
            ENV[key] = value
          end
        end
        `#{output_command} 2>&1`
      ensure
        ENV.update(old_env) if env
      end

      if (line_column_match = settings[:line_column_match])
        output.gsub! \
          line_column_match,
          "<a href='txmt://open/?url=file://#{filepath}&line=\\1&column=\\2'>L\\1</a> "
      elsif (line_match = settings[:line_match])
        output.gsub! \
          line_match,
          "<a href='txmt://open/?url=file://#{filepath}&line=\\1'>L\\1</a>"
      end

      if (extra_gsubs = settings[:extra_gsubs])
        extra_gsubs.each do |pattern, replacement|
          if replacement.is_a?(Proc)
            output.gsub! pattern, &replacement
          else
            output.gsub! pattern, replacement
          end
        end
      end

      output = output.squeeze("\n").strip.chomp
      next if output.empty?
      output_something ||= true
      puts output
    end

    puts "(no output)" unless output_something
  end
end
