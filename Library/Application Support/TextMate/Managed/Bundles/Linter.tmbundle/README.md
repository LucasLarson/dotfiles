# Linter.tmbundle
Provides Linting functionality to TextMate to make it easier to write better quality code.

## Features
- Linting on request of Bash, JSON, Markdown and Ruby files
- Strips trailing whitespace on request from the end of lines (except after Ruby `__END__` blocks)
- Adds trailing newlines on request to the end of files missing them
- If set in `.tm_properties`'s [`scopeProperties`](https://gist.github.com/dvessel/1478685#other) (space separated, set either globally or for a given language like `[ source.ruby ]`):
  - `bundle.linter.lint-on-save` automatically runs Linter on save for supported file types
  - `bundle.linter.strip-whitespace-on-save` automatically strips trailing whitespace on save
  - `bundle.linter.ensure-newline-on-save` automatically adds a training newline on save
  - `bundle.linter.fix-on-save` automatically fixes lints if possible (e.g. with RuboCop)

## Linters
### Bash
- `bash -n` (found in `LINTER_BASH`, `BASH` or `PATH` environment variables)
- [`shellcheck`](https://www.shellcheck.net)  (`brew install shellcheck`, found in `LINTER_SHELLCHECK`, `SHELLCHECK` or `PATH` environment variables)

### JSON
- `JSON.parse` in Ruby (found in `LINTER_RUBY`, `RUBY`  or `PATH` environment variables)
- [`jsonlint`](https://jsonlint.com) (`brew install jsonlint`, found in `LINTER_JSONLINT`, `JSONLINT` or `PATH` environment variables)

### Markdown
- [list of hedge words](https://github.com/MikeMcQuaid/Linter.tmbundle/blob/master/Support/lib/hedge_words.rb)
- [`alex`](https://github.com/wooorm/alex) (`brew install alex`, found in `LINTER_ALEX`, `ALEX` or `PATH` environment variables)
- [`write-good`](https://github.com/wooorm/alex) (`brew install write-good`, found in `LINTER_ALEX`, `ALEX` or `PATH` environment variables)

### Ruby
- `ruby -wc` (found in `LINTER_RUBY`, `RUBY`  or `PATH` environment variables)
- [`rubocop`](http://rubocop.readthedocs.io/en/latest/) (`gem install --user rubocop`, found in `LINTER_RUBOCOP`, `RUBOCOP` or `PATH` environment variables)

## Installation

```bash
mkdir -p ~/Library/Application\ Support/TextMate/Bundles
cd ~/Library/Application\ Support/TextMate/Bundles
git clone https://github.com/MikeMcQuaid/Linter.tmbundle
```

## Status
The above features work for my day-to-day use.

Tested using TextMate 2. May work in TextMate 1 or Sublime Text; I've no idea.

[Patches welcome](https://github.com/MikeMcQuaid/Linter.tmbundle/pulls).

## Maintainers
[@MikeMcQuaid](https://github.com/MikeMcQuaid)

## License
Linter.tmbundle is under the [MIT License](http://en.wikipedia.org/wiki/MIT_License). The full license text is
available in
[LICENSE.txt](https://github.com/MikeMcQuaid/Linter.tmbundle/blob/master/LICENSE.txt).
