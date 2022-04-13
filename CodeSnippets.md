# Code snippets

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [copy, paste, return](#copy-paste-return)
  - [detail](#detail)
- [Mackup](#mackup)
  - [add](#add)
    - [manual](#manual)
      - [lists](#lists)
        - [applications](#applications)
      - [Homebrew](#homebrew)
        - [Cask](#cask)
      - [MANPATH](#manpath)
        - [man pages](#man-pages)
      - [pip packages](#pip-packages)
- [apk](#apk)
  - [testing](#testing)
- [list everything recursively in a directory](#list-everything-recursively-in-a-directory)
  - [with full paths](#with-full-paths)
    - [and metadata](#and-metadata)
    - [lines, words, characters](#lines-words-characters)
- [search](#search)
  - [`grep`](#grep)
  - [locate all](#locate-all)
- [PATH](#path)
  - [executables](#executables)
- [text editing](#text-editing)
  - [export output](#export-output)
    - [sort](#sort)
  - [EOL and EOF encoding](#eol-and-eof-encoding)
- [make invisible](#make-invisible)
- [create an alias](#create-an-alias)
- [launch services](#launch-services)
  - [reset](#reset)
  - [repair site disk permissions](#repair-site-disk-permissions)
    - [date modified modify](#date-modified-modify)
- [C, C++](#c-c)
  - [flags](#flags)
    - [C++ features before wide support](#c-features-before-wide-support)
  - [apply `clang-format` recursively](#apply-clang-format-recursively)
  - [run `cpplint` recursively](#run-cpplint-recursively)
  - [run `cppcheck` recursively](#run-cppcheck-recursively)
  - [compile all files of type .𝑥 in a directory](#compile-all-files-of-type-𝑥-in-a-directory)
    - [C](#c)
    - [C++](#c-1)
    - [Clang](#clang)
- [Gatekeeper](#gatekeeper)
- [Git](#git)
  - [`init` via GitHub](#init-via-github)
  - [`git add`](#git-add)
  - [`git diff`](#git-diff)
  - [`git commit`](#git-commit)
    - [with subject and body](#with-subject-and-body)
    - [in the past](#in-the-past)
  - [`git config`](#git-config)
    - [editor](#editor)
  - [`git tag`](#git-tag)
- [Numbers](#numbers)
  - [Affixes](#affixes)
- [Operating system](#operating-system)
  - [Identify](#identify)
- [parameter expansion](#parameter-expansion)
- [redirection](#redirection)
- [rename files](#rename-files)
  - [replace](#replace)
- [split enormous files into something manageable](#split-enormous-files-into-something-manageable)
- [SSH](#ssh)
  - [`ls` on Windows](#ls-on-windows)
- [variables](#variables)
- [wget](#wget)
- [Wi-Fi](#wi-fi)
  - [Windows password](#windows-password)
  - [macOS password](#macos-password)
- [Xcode](#xcode)
  - [signing](#signing)
- [Zsh](#zsh)
  - [array types](#array-types)
  - [troubleshooting](#troubleshooting)
- [housekeeping](#housekeeping)
  - [docker](#docker)
  - [brew](#brew)
  - [npm](#npm)
  - [gem](#gem)
  - [Xcode, JetBrains, Carthage, Homebrew](#xcode-jetbrains-carthage-homebrew)
- [delete](#delete)
  - [empty directories](#empty-directories)
  - [compare two folders](#compare-two-folders)
  - [purge memory cache](#purge-memory-cache)

<!-- /TOC -->

## copy, paste, return

```shell
update='1'; IFS="$(printf ' \t\n|')"; IFS="${IFS%|}"; command clear; command clear
printf '                 .___       __\n __ ________   __\174 _\057____ _\057  \174_  ____\n\174  \174  \134____ \134 \057 __ \174\134__  \134\134   __\134\057 __ \134\n\174  \174  \057  \174_\076 \076 \057_\057 \174 \057 __ \134\174  \174 \134  ___\057\n\174____\057\174   __\057\134____ \174\050____  \057__\174  \134___  \076\n'
printf '      \174__\174        \134\057     \134\057          \134\057\n a Lucas Larson production\n\n' && command sleep 1; unset PS4
printf '\n\360\237\223\241  verifying network connectivity'; command sleep 1; i='0'; while test "${i-}" -lt "$(
printf '2 ^ 7 + 1\n' | command bc)"; do if test "$((i / 3 % 2))" -eq '0'; then
printf '.'; else
printf '\b'; fi; i="$((i + 1))"; done; unset i
printf '\n\n'; set -o nounset; { command ping -q -i 1 -c 1 -- one.one.one.one >/dev/null 2>&1 && command ping -q -i 1 -c 1 -- 8.8.8.8 >/dev/null 2>&1; } || {
printf 'No internet connection detected.\nAborting update.\n'; exit "${update:-1}"; }
printf '\360\237\215\272  checking for Homebrew installation...'; if command -v brew >/dev/null 2>&1; then
printf '  \342\234\205  found\n'
printf '\360\237\215\272  checking for Homebrew updates...\n'; command brew update; command brew upgrade --greedy; command brew upgrade --cask --greedy
command brew install --debug --verbose --include-test --HEAD --display-times --git -- git
command brew install --debug --verbose --include-test --HEAD --display-times --git -- mackup
command brew install --debug --verbose --include-test --HEAD --display-times --git -- shellcheck;
command brew install --debug --verbose --include-test --HEAD --display-times --git -- shfmt
command brew install --debug --verbose --include-test --HEAD --display-times --git -- zsh
command brew generate-man-completions; else
printf 'No Homebrew installation detected.\n\n'; fi
printf '\360\237\217\224  checking for Alpine Package Keeper installation...\n'; if command -v apk >/dev/null 2>&1; then
printf '\360\237\217\224  apk update...\n'; command apk update --progress --verbose --verbose
printf '\n\360\237\217\224  apk upgrade...\n'; command apk upgrade --update-cache --progress --verbose --verbose
printf '\n\360\237\217\224  apk fix...\n'; command apk fix --progress --verbose --verbose
printf '\n\360\237\217\224  apk verify...\n'; command apk verify --progress --verbose --verbose
printf '\360\237\217\224  apk verify complete...\n\n'; else
printf 'no Alpine Package Keeper installation detected.\n\n'; fi
printf 'checking access to Software Update...\n'; if command -v softwareupdate >/dev/null 2>&1; then
printf '\360\237\215\216  '; command softwareupdate --list --all --verbose; else
printf 'no Software Update installation detected.\n\n'; fi
printf 'checking for Xcode installation...\n'; if command -v xcrun >/dev/null 2>&1; then
printf 'removing unavailable device simulators...\n'; command xcrun simctl delete unavailable; else
printf 'no Xcode installation detected.\n\n'; fi
printf '\342\232\233\357\270\217  checking for Atom installation...\n'; if command -v apm >/dev/null 2>&1; then command apm upgrade --no-confirm; else
printf 'no Atom installation detected.\n\n'; fi
printf 'checking for Rust installation...\n'; if command -v rustup >/dev/null 2>&1; then command rustup update; else
printf 'no Rust installation detected.\n\n'; fi
printf 'checking for npm installation...\n'; if command -v npm >/dev/null 2>&1; then
printf '...and whether this device is can update Node quickly...\n'; if test "$((${COLUMNS:-80} * ${LINES:-24}))" -ge "$((80 * 24))"; then while test -n "$(command find -- "${HOME-}"'/.npm-packages' -type f ! -name "$(
printf "*\n*")" -name '.DS_Store' -print)"; do command find -- "${HOME-}"'/.npm-packages' -type f ! -name "$(
printf "*\n*")" -name '.DS_Store' -print -delete; done; command npm install npm --global; while test -n "$(command find -- "${HOME-}"'/.npm-packages' -type f ! -name "$(
printf "*\n*")" -name '.DS_Store' -print)"; do command find -- "${HOME-}"'/.npm-packages' -type f ! -name "$(
printf "*\n*")" -name '.DS_Store' -print -delete; done; command npm update --global --verbose; else
printf 'skipping Node update...\n\n'; command sleep 1
printf 'to update Node later, run:\n\n'
printf '    npm install npm --global \046\046 \134\n'
printf '    npm update --global --verbose\n\n\n'; command sleep 3; fi; else
printf 'no npm installation detected.\n\n'; fi
printf 'checking for RubyGems installation...\n'; if command -v gem >/dev/null 2>&1; then
printf 'updating RubyGems...\n'; command gem update --system --verbose; command gem update --verbose; if command bundle update >/dev/null 2>&1; then command bundle update --verbose 2>/dev/null; fi; if command bundle install >/dev/null 2>&1; then command bundle install --verbose 2>/dev/null; fi
printf 'checking for CocoaPods installation...\n'; if command bundle exec pod install >/dev/null 2>&1; then command bundle exec pod install --verbose 2>/dev/null; fi; if command pod repo update >/dev/null 2>&1; then command pod repo update --verbose; command pod repo update --verbose; fi; else
printf 'no RubyGems installation detected.\n\n'; fi; if command -v rbenv >/dev/null 2>&1; then command rbenv rehash; fi; if command -v c_rehash >/dev/null 2>&1; then command c_rehash; fi; if command -v python >/dev/null 2>&1; then
printf '\n\360\237\220\215  verifying Python\342\200\231s packager is up to date...\n'; command python -m pip install --upgrade --verbose --verbose --verbose -- pip
printf 'verifying pip installation...\n'; if command -v pip >/dev/null 2>&1; then
printf '\n\360\237\220\215  updating outdated Python packages...\n'; for package in $(command pip list --outdated --format freeze); do command pip install --upgrade --verbose --verbose --verbose -- "${package%%=*}"; done; unset package; fi
printf 'checking for pyenv installation...\n'; if command -v pyenv >/dev/null 2>&1; then
printf 'rehashing pyenv shims...\n'; command pyenv rehash; else
printf 'no pyenv installation detected.\n\n'; fi
printf 'checking for Conda installation...\n'; if command -v conda >/dev/null 2>&1; then command conda update --yes --all; else
printf 'no Conda installation detected.\n\n'; fi; fi; if command -v omz >/dev/null 2>&1; then { set +o nounset; } 2>/dev/null; omz update 2>/dev/null; fi; { set -o allexport; set +o errexit; set +o noclobber; set +o nounset; set +o verbose; set +o xtrace; } 2>/dev/null
test -r "${HOME-}"'/.'"${SHELL##*[-./]}"'rc' && . "${HOME-}"'/.'"${SHELL##*[-./]}"'rc'; if command -v rehash >/dev/null 2>&1; then rehash; fi; unset update
printf '\n\n\342%s\234\205  done\041\n' "${update-}"; $(command -v exec) -l -- "${SHELL##*[-./]}" # 2022-03-17
```

### detail

`xcode-select --switch /Applications/Xcode.app || xcode-select --switch /Applications/Xcode-beta.app || xcode-select --install && \`<br/>
`xcrun simctl delete unavailable && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/d7406c3bb347af9fb1734885ed571117a5dbf90a/README.md#remove-all-unavailable-simulators) `\`<br/>
`brew update --debug --verbose && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/launchagents.md#periodic-homebrew-update-and-upgrade)`,` [via](https://stackoverflow.com/a/47664603) `\`<br/>
`brew upgrade && \`<br/>
`brew upgrade --cask && #` [via](https://github.com/hisaac/hisaac.net/blob/8c63d51119fe2a0f05fa6c1c2a404d12256b0594/source/_posts/2018/2018-02-12-update-all-the-things.md#readme), [via](https://github.com/Homebrew/homebrew-cask/pull/88681) `\`<br/>
`brew install mackup --head && #` 0.8.29 [2020-06-06](https://github.com/lra/mackup/blob/master/CHANGELOG.md#mackup-changelog) `\`<br/>
`mackup backup --force --root \`<br/>
`omz update && #` [via](https://github.com/ohmyzsh/ohmyzsh/blob/3935ccc/lib/functions.zsh#L9-L12) `\`<br/>
`git clone --recurse-submodules --depth 1 --branch main --verbose --progress #` [via](https://github.com/hisaac/Tiime/blob/ff1a39d6765d8ae5c9724ca84d5c680dff4c602e/README.md#bootstrapping-instructions), [via](https://stackoverflow.com/a/50028481) `\`<br/>
`git submodule update --init --recursive && #` [via](https://stackoverflow.com/a/10168693) `\`<br/>
`npm install npm --global && #` [via](https://github.com/mathiasbynens/dotfiles/blob/e42090bf49f860283951041709163653c8a2c522/.aliases#L51-L52), [via](https://docs.npmjs.com/misc/config#shorthands-and-other-cli-niceties) `\`<br/>
`npm update --global --verbose && #` 6.14.5 [2020-05-04](https://www.npmjs.com/package/npm?activeTab=versions#versions) `\`<br/>
`apm upgrade --no-confirm && #` via npm analogy `\`<br/>
`gem update --system && #`  3.1.4 [2020-06-03](https://blog.rubygems.org) `\`<br/>
`gem update && \`<br/>
`gem install bundler --pre && #`  2.1.4 [2020-01-05](https://rubygems.org/gems/bundler/versions) `\`<br/>
`gem install cocoapods --pre && #`  1.9.3 [2020-05-29](https://rubygems.org/gems/cocoapods/versions) `\`<br/>
`bundle update && #` [via](https://github.com/ffi/ffi/issues/651#issuecomment-513835103) `\`<br/>
`bundle install --verbose && \`<br/>
`bundle exec pod install --verbose && \`<br/>
`pod repo update && pod repo update && \`<br/>
`pod install && \`<br/>
`rbenv rehash && pyenv rehash && \`<br/>
`python -m pip install --upgrade pip` && # 20.1.1 [2020-05-19](https://pip.pypa.io/en/stable/news/#id1) [via](https://opensource.com/article/19/5/python-3-default-mac#comment-180271), [via](https://github.com/pypa/pip/blob/52309f98d10d8feec6d319d714b0d2e5612eaa47/src/pip/_internal/self_outdated_check.py#L233-L236) `\`<br/>
`pip list --outdated --format freeze \`<br/>
    `| grep --invert-match '^\-e' \`<br/>
    `| cut --delimiter = --fields 1 \`<br/>
    `| xargs -n1 pip install --upgrade && #` [via](https://stackoverflow.com/revisions/3452888/14) `\`<br/>
`pip install --upgrade $(pip freeze | cut --delimiter '=' --fields 1) && #` [via](https://web.archive.org/web/20200508173219id_/coderwall.com/p/quwaxa/update-all-installed-python-packages-with-pip#comment_29830) `\`<br/>
`pipenv shell &&` # [via](https://github.com/pypa/pipenv/blob/bfbe1304f63372a0eb7c1531590b51195db453ea/pipenv/core.py?instructions_while_running_pipenv_install#L1282) `\`<br/>
`pipenv install --dev && #` [via](https://stackoverflow.com/a/49867443) `\`<br/>
`rustup update && #` 1.44.1 [2020-06-18](https://github.com/rust-lang/rust/releases) `\`<br/>
`brew install carthage --head && #` 0.36.0 [2020-09-18](https://github.com/Carthage/Carthage/releases) `\`<br/>
`carthage update --verbose --no-use-binaries && #` [via](https://stackoverflow.com/a/41526660) `\`<br/>
`brew install swiftgen --head && #`  6.2.0 [2019-01-29](https://github.com/SwiftGen/SwiftGen/releases) `\`<br/>
`swiftgen && \`<br/>
`brew install swiftlint --head && #` 0.40.3 [2020-09-22](https://github.com/realm/SwiftLint/releases) `\`<br/>
`swiftlint autocorrect && \`<br/>
`git gc && \`<br/>
`# gradle build --refresh-dependencies --warning-mode all && #` [via](https://stackoverflow.com/a/35374051) `\`<br/>
`. ~/.${SHELL##*/}rc && \`<br/>
`printf '\n\n\342%s\234\205 done\041\n\n' "$update" && #` [via](https://stackoverflow.com/a/30762087), [via](https://stackoverflow.com/a/602924), [via](https://github.com/koalaman/shellcheck/wiki/SC2059/0c9cfe7e8811d3cafae8df60f41849ef7d17e296#problematic-code) `\`<br/>
`#` note successful finish before restarting the shell `\`<br/>
`exec -l "${SHELL##*/}" #` [via](https://github.com/mathiasbynens/dotfiles/commit/cb8843bea74f1d223ea2967c7a891ca76c9e54e9#diff-ec67f41a7a08f67e6d486db809809f700007e2d58895d67e842ff21123adaee4R145-R146)

## Mackup

### add

#### manual

<!--
to add dotfiles, for example, of the variety [Mackup](https://github.com/lra/mackup) might’ve but hasn’t
`add='`**~/Desktop/example.txt**`' && cp ~/$add $DOTFILES/$add && mv ~/$add ~/.Trash && ln --symbolic $DOTFILES/$add ~/$add`
-->

##### lists

###### applications

```shell
command find -- /System/Applications /Applications -maxdepth 3 -type d -name '*.app' -print0 | command xargs -0 basename -a -s '.app' -- | LC_ALL='C' command sort -u | LC_ALL='C' command sort -f
```

On Alpine Linux, generate a list of installed packages with:<br/>
`command apk --verbose --verbose info | LC_ALL='C' command sort #` [via](https://wiki.alpinelinux.org/wiki/Special:PermanentLink/10079#Listing_installed_packages)

##### Homebrew

```shell
command brew list -1 --formula
```

###### Cask

```shell
command brew list -1 --cask
```

##### MANPATH

```shell
printf '%s\n' "${MANPATH[@]-}" | command sed -e 's|:|\n|g'
```

###### man pages

Definintions of the numbers that follow `man` commands.

1. Executable programs or shell commands
1. System calls (functions provided by the kernel)
1. Library calls (functions within program libraries)
1. Special files (usually found in `/dev`)
1. File formats and conventions, `/etc/passwd` for example
1. Games
1. Miscellaneous (including macro packages and conventions)
1. System administration commands (usually only for `root`)

[via](https://web.archive.org/web/20200627082020id_/manpages.ubuntu.com/cgi-bin/search.py?q=man&titles=Title#distroAndSection)

##### pip packages

```shell
{ command pip list || command pip3 list; } 2>/dev/null
```

## apk

### testing

`apk add foo #` unavailable? `\`<br/>
`#` then try `\`<br/>
`apk add foo@testing #` [via](https://web.archive.org/web/20201014175951id_/stackoverrun.com/ja/q/12834672#text_a46821207)

## list everything recursively in a directory

### with full paths

`find -- .` # [via](https://www.cyberciti.biz/faq/how-to-list-directories-in-linux-unix-recursively/)

#### and metadata

`find -- . -ls`

#### lines, words, characters

in, for example, a C++ project directory, measuring only `.cpp` and `.hpp` files

`find -- * \( -name '*.cpp' -or -name '*.hpp' \) -print0 | xargs -0 wc | sort -n -r` # [via](https://web.archive.org/web/20210216223000id_/github.com/bryceco/GoMap/issues/495#issuecomment-780111175)

## search

### `grep`

search for the word “example” inside the current directory which is “.”<br/>
`grep --ignore-case --line-number --recursive 'example' .`

### locate all

for example, locate all JPEG files:<br/>
`command find -- . -type f \( -name '*.JPEG' -o -name '*.JPG*' -o -name '*.jpeg*' -o -name '*.jpg*' \)`

## PATH

```shell
printf '%s\n' "${PATH[@]-}" | command sed -e 's|:|\n|g'
```

### executables

`print -l ${^path-}/*(-*N)` # [via](https://web.archive.org/web/20210206194844id_/grml.org/zsh/zsh-lovers#_unsorted_misc_examples)

## text editing

### export output

`printf 'First Name\n'` **>**`./ExampleFileWithGivenName.txt` # create a text file with “First Name” and a new line<br/>
`printf 'Other First Name\n'` **>**`./ExampleFileWithGivenName.txt` # the “`>`” *overwrites* the existing file<br/>
`printf 'Last Name\n'` **>>**`./ExampleFileWithGivenName.txt` # the “`>>`” *appends* to the existing document

#### sort

`command env >./example.txt` # save an unordered list of `env` variables<br/>
`command env | LC_ALL='C' command sort >./example.txt` # [via](https://howtogeek.com/439199/15-special-characters-you-need-to-know-for-bash) save the variables in an alphabetically ordered list

### EOL and EOF encoding

find `(?<![\r\n])$(?![\r\n])` # [via](https://stackoverflow.com/a/34958727)<br/>
replace `\r\n`

## make invisible

`chflags -hvv hidden example.txt`<br/>
`-h` for symbolic links, if applicable, but not their targets<br/>
`-v`₁ for verbose<br/>
`-v`₂ for printing the old and new flags in octal to `stdout`

## create an alias

`ln --symbolic file shortcut #` [via](https://reddit.com/comments/1qt0z/_/c1qtge/)<br/>
(just like `cp existing new`)

## launch services

### reset

remove bogus entries from Finder’s “Open With” menu ([via](https://github.com/mathiasbynens/dotfiles/blob/e42090bf49f860283951041709163653c8a2c522/.aliases#L69-L70))<br/>
`/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -seed -r -domain local -domain system -domain user && killall Finder`

### repair site disk permissions

`find -- . -type d -exec chmod 755 '{}' ';' && \`<br/>
`find -- . -type f -exec chmod 644 '{}' ';' #` [via](https://wordpress.org/support/article/hardening-wordpress/#changing-file-permissions)

#### date modified modify

`touch -t 2003040500 file.txt` # date modified → 2020-03-04 5:00am

## C, C++

### flags

`-Wall -Wextra -pedantic`<br/>
`#ifdef __APPLE__`<br/>
    `-Weverything <!--` do not use ([via](https://web.archive.org/web/20190926015534id_/quuxplusone.github.io/blog/2018/12/06/dont-use-weverything/#for-example-if-you-want-to-see-a)) `-->`<br/>
`#endif`<br/>
`-Woverriding-method-mismatch -Weffc++ -Wcall-to-pure-virtual-from-ctor-dtor -Wmemset-transposed-args -Wreturn-std-move -Wsizeof-pointer-div -Wdefaulted-function-deleted` # [via](https://github.com/jonreid/XcodeWarnings/issues/8#partial-discussion-header)<br/>
`-lstdc++ #` [via](https://web.archive.org/web/20200517174250id_/unspecified.wordpress.com/2009/03/15/linking-c-code-with-gcc/#post-54) but this might – or might not – be helpful on macOS using gcc or g++

#### C++ features before wide support

for example, C++17’s `<filesystem>`<br/>
`-lstdc++fs`

### apply `clang-format` recursively

[via](https://stackoverflow.com/a/36046965)<br/>

```shell
command clang-format --version 2>/dev/null || return 2; command sleep 1; IndentWidth='2'; ColumnLimit='79'; printf 'applying clang-format to all applicable files in %s...\n' "${PWD##*/}"; command sleep 1; while getopts i:w: opt;do case "${opt-}" in (i) IndentWidth="${OPTARG-}"; printf 'setting \140IndentWidth\140 to %d\n' "${IndentWidth-}"; command sleep 1;; \
(w) ColumnLimit="${OPTARG-}"; printf 'setting \140ColumnLimit\140 to %d\n\n\n' "${ColumnLimit-}"; command sleep 1 ;; (*) printf 'only \140-i <indent width>\140 and \140-w <number of columns>\140 are supported\n'; return 1; esac; done; command find -- . -type f ! -path '*.git/*' ! -path '*/Test*' ! -path '*/t/*' ! -path '*/test*' ! -path '*node_modules/*' ! -path '*vscode*' \( \
-name '*.adb' -o -name '*.ads' -o -name '*.asm' -o -name '*.ast' -o -name '*.bc' -o -name '*.C' -o -name '*.c' -o -name '*.C++' -o -name '*.c++' -o -name '*.c++m' -o -name '*.CC' -o -name '*.cc' -o -name '*.ccm' -o -name '*.cl' -o -name '*.clcpp' -o -name '*.cp' -o -name '*.CPP' -o -name '*.cpp' -o -name '*.cppm' -o \
-name '*.cs' -o -name '*.cu' -o -name '*.cuh' -o -name '*.cui' -o -name '*.CXX' -o -name '*.cxx' -o -name '*.cxxm' -o -name '*.F' -o -name '*.f' -o -name '*.F90' -o -name '*.f90' -o -name '*.F95' -o -name '*.f95' -o -name '*.FOR' -o -name '*.for' -o -name '*.FPP' -o -name '*.fpp' -o -name '*.gch' -o \
-name '*.H' -o -name '*.h' -o -name '*.h++' -o -name '*.hh' -o -name '*.hip' -o -name '*.hp' -o -name '*.hpp' -o -name '*.hxx' -o -name '*.i' -o -name '*.ifs' -o -name '*.ii' -o -name '*.iim' -o -name '*.inc' -o -name '*.inl' -o -name '*.java' -o -name '*.lib' -o -name '*.ll' -o -name '*.M' -o \
-name '*.m' -o -name '*.mi' -o -name '*.mii' -o -name '*.mm' -o -name '*.pch' -o -name '*.pcm' -o -name '*.proto' -o -name '*.protodevel' -o -name '*.rs' -o -name '*.S' -o -name '*.s' -o -name '*.tcc' -o -name '*.td' -o -name '*.tlh' -o -name '*.tli' -o -name '*.tpp' -o -name '*.ts' -o -name '*.txx' \) \
-exec clang-format -i --style "{IndentWidth: ${IndentWidth-}, ColumnLimit: ${ColumnLimit-}}" --verbose --fcolor-diagnostics --print-options '{}' '+'; unset -- IndentWidth 2>/dev/null; unset -- ColumnLimit 2>/dev/null; printf '\n\n\342\234\205  done\041\n'
```

### run `cpplint` recursively

`cpplint --verbose=0 --linelength=79 --recursive --extensions=c++,cc,cp,cpp,cxx,h,h++,hh,hp,hpp,hxx . >>./cpplint.txt`

### run `cppcheck` recursively

`cppcheck --force -I $CPATH . >>./cppcheck.txt`

### compile all files of type .𝑥 in a directory

#### C

[via](https://stackoverflow.com/q/33662375)<br/>
`gcc -std=c89 --verbose -save-temps -v -Wall -Wextra -pedantic $(find -- . -type f -regex '*.c')`

#### C++

`g++ -std=c++2a --verbose -Wall -Wextra -pedantic -save-temps -v -pthread -fgnu-tm -lm -latomic -lstdc++ $(find -- . -iname '*.cpp')`

#### Clang

`clang++ -std=c++2a --verbose -Wall -Wextra -pedantic -v -lm -lstdc++ -pthread -save-temps $(find -- . -iname '*.cpp')`

## Gatekeeper

do not disable it, because that would allow you to install any software, even if unsigned, even if malicious:<br/>
`sudo spctl --master-disable #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/bd25a136655e63fcb7f3462a8dc7105f30093e54/README.md#manage-gatekeeper)

## Git

### `init` via GitHub

`git push --set-upstream git@github.com:LucasLarson/$(git rev-parse --show-toplevel | xargs basename).git $(git rev-parse --abbrev-ref HEAD)`

### `git add`

[via](https://stackoverflow.com/a/15011313)
| content to add                  | git command                       |
| ------------------------------- | --------------------------------- |
| modified files only             | `git add --updated || git add -u` |
| everything except deleted files | `git add .`                       |
| everything                      | `git add --all || git add -A`     |

### `git diff`

more detailed `git diff` and how I once found an LF‑to‑CRLF‑only difference<br/>
`git diff --raw`

### `git commit`

#### with subject and body

`git commit --message 'subject' --message 'body' #` [via](https://stackoverflow.com/a/40506149)

#### in the past

to backdate a commit:<br/>
`GIT_TIME='`**2000-01-02T15:04:05 -0500**`' GIT_AUTHOR_DATE=$GIT_TIME GIT_COMMITTER_DATE=$GIT_TIME git commit --message 'add modifications made at 3:04:05pm EST on January 2, 2000' #` [via](https://stackoverflow.com/questions/3895453/how-do-i-make-a-git-commit-in-the-past#comment97787061_3896112)

### `git config`

#### editor

Vim<br/>
`git config --global core.editor /usr/local/bin/vim`<br/>
Atom [via](https://stackoverflow.com/a/31389989)<br/>
`git config --global core.editor "atom --wait"`

### `git tag`

`git tag v𝑖.𝑗.𝑘 #` where 𝑖, 𝑗, and 𝑘 are non-negative integers representing [SemVer](https://github.com/semver/semver/blob/8b2e8eec394948632957639dfa99fc7ec6286911/semver.md#summary) (semantic versioning) major, minor, and patch releases<br/>
`git push origin v𝑖.𝑗.𝑘 #` push the unannotated tag [via](https://stackoverflow.com/a/5195913)

## Numbers

### Affixes

| Definition  | Prefix | Suffix |
| ----------- | ------ | ------ |
| binary      | `b`𝑛   | 𝑛`₂`   |
| octal       | `o`𝑛   | 𝑛`₈`   |
| decimal     | `d`𝑛   | 𝑛`₁₀`  |
| hexadecimal | `x`𝑛   | 𝑛`₁₆`  |

## Operating system

### Identify

`command -v uname >/dev/null 2>&1 && \`<br/>
`printf '\n\140uname -a\140:\n%s\n\n' "$(uname -a)"; \`<br/>
`command -v sw_vers >/dev/null 2>&1 && #` [via](https://apple.stackexchange.com/a/368244) `\`<br/>
`printf '\n\140sw_vers\140:\n%s\n\n' "$(sw_vers)"; \`<br/>
`command -v lsb_release >/dev/null 2>&1 && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-from-the-command-line) `\`<br/>
`printf '\n\140lsb_release --all\140:\n%s\n\n' "$(lsb_release --all)"; \`<br/>
`[ -r /etc/os-release ] && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-using-the-etcos-release-file) `\`<br/>
`printf '\140cat /etc/os-release\140:\n%s\n\n' "$(cat /etc/os-release)"`

## parameter expansion

[via](https://opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)
|                        | *parameter* Set and Not Null | *parameter* Set But Null | *parameter* Unset |
| ---------------------- | ---------------------------- | ------------------------ | ----------------- |
| ${*parameter*:-*word*} | substitute *parameter*       | substitute *word*        | substitute *word* |
| ${*parameter*-*word*}  | substitute *parameter*       | substitute null          | substitute *word* |
| ${*parameter*:=*word*} | substitute *parameter*       | assign *word*            | assign *word*     |
| ${*parameter*=*word*}  | substitute *parameter*       | substitute null          | assign *word*     |
| ${*parameter*:?*word*} | substitute *parameter*       | error, exit              | error, exit       |
| ${*parameter*?*word*}  | substitute *parameter*       | substitute null          | error, exit       |
| ${*parameter*:+*word*} | substitute *word*            | substitute null          | substitute null   |
| ${*parameter*+*word*}  | substitute *word*            | substitute *word*        | substitute null   |

## redirection

[via](https://askubuntu.com/a/350216)

| syntax        | meaning                                  | POSIX compliance |
| ------------- | ---------------------------------------- | ---------------- |
| `>file`       | redirect `stdout` to `file`              | ✅                |
| `1>file`      | redirect `stdout` to `file`              | ✅                |
| `2>file`      | redirect `stderr` to `file`              | ✅                |
| `>file 2>&1`  | redirect `stdout` and `stderr` to `file` | ✅                |
| `&>file`      | redirect `stdout` and `stderr` to `file` | 🚫                |
| `>>file 2>&1` | append `stdout` and `stderr` to `file`   | ✅                |
| `&>>/file`    | append `stdout` and `stderr` to `file`   | 🚫                |

## rename files

`brew install --upgrade rename && #` [via](https://stackoverflow.com/a/31694356) `\`<br/>
`rename --dry-run --verbose --subst searchword replaceword *`

### replace

recursively edit files, replacing each instance of `bin/bash` with `usr/bin/env zsh`

```shell
find -- . -type f -exec sed -i 's|bin/bash|usr/bin/env zsh|g' '{}' '+'
```

## split enormous files into something manageable

if your example.csv has too many rows ([via](https://web.archive.org/web/20181210131347/domains-index.com/best-way-view-edit-large-csv-files/#post-12141))<br/>
`split -l 2000 example.csv; for i in *; do mv "$i" "$i.csv"; done`

## SSH

`ssh username@example.com`

### `ls` on Windows

`dir` # [via](https://stackoverflow.com/a/58740114)

## variables

`$PWD` # the name of the current directory and its entire path
`${PWD##*/}` # [via](https://stackoverflow.com/a/1371283) the name of only the current directory

## wget

wget_server='`**example.com**`'; if command -v wget2 >/dev/null 2>&1; then utility='wget2'; else utility='wget'; fi; \
command "${utility-}" --level=0 --mirror --continue --verbose \
--append-output=./"${wget_server-}".log --execute robots=off --restrict-file-names=nocontrol --timestamping --debug --recursive --progress=bar --no-check-certificate --random-wait \
--referer=https://"${wget_server-}" --adjust-extension --page-requisites --convert-links --server-response \
https://"${wget_server-}"; unset wget_server utility`

## Wi-Fi

### Windows password

`netsh wlan show profile WiFi-name key=clear #` [via](https://reddit.com/r/LifeProTips/comments/d5vknk/lpt_if_you_ever_forget_your_wifi_password_or_you/)

### macOS password

`security find-generic-password -wa ExampleNetwork #` [via](https://www.labnol.org/software/find-wi-fi-network-password/28949/)

## Xcode

### signing

`PRODUCT_BUNDLE_IDENTIFIER = net.LucasLarson.$(PRODUCT_NAME:rfc1034identifier);`<br/>
`PRODUCT_NAME = $(PROJECT_NAME) || $(PRODUCT_NAME:c99extidentifier) || $(TARGET_NAME)`<br/>
`DEVELOPMENT_TEAM = Z25963JBNP;`<br/>
`DevelopmentTeam = Z25963JBNP;`

## Zsh

### array types

`<<<${(t)path-} #` [via](https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path)

### troubleshooting

Add `zmodload zsh/zprof` at the top of `~/.zshrc` and `zprof` at the bottom of
it. Restart restart to get a profile of startup time usage.&nbsp;[via](https://web.archive.org/web/20210112072135id_/reddit.com/r/zsh/comments/kums6q/zsh_very_slow_to_open_how_to_debug/gisz7nc/)

## housekeeping

### docker

`docker system prune --all #` [via](https://news.ycombinator.com/item?id=25547876#25547876)

### brew

`brew doctor --debug --verbose && \`<br/>
`brew cleanup --debug --verbose && #` [via](https://stackoverflow.com/a/41030599) `\`<br/>
`brew audit cask --strict --token-conflicts`

### npm

`npm audit fix && \`<br/>
`npm doctor && #` creates empty `node_modules` directories `\`<br/>
`find -- node_modules -empty -type d -delete #` deletes them [via](https://perma.cc/YNL2-FY3Z)

### gem

`gem cleanup --verbose`

### Xcode, JetBrains, Carthage, Homebrew

```shell
trash_developer='1'; command sleep 1; set -o errexit; set -o nounset; set -o xtrace; trash_date="$(command date -u '+%Y%m%d_%s')" \
command mkdir -p "${HOME-}"'/Library/Developer/Xcode/DerivedData' && command mv -i "${HOME-}"'/Library/Developer/Xcode/DerivedData' "${HOME-}"'/.Trash/Xcode-'"${trash_date-}" \
command mkdir -p "${HOME-}"'/Library/Developer/Xcode/UserData/IB Support' && command mv -i "${HOME-}"'/Library/Developer/Xcode/UserData/IB Support' "${HOME-}"'/.Trash/Xcode⁄UserData⁄IB Support-'"${trash_date-}" \
command mkdir -p "${HOME-}"'/Library/Caches/JetBrains' && command mv -i "${HOME-}"'/Library/Caches/JetBrains' "${HOME-}"'/.Trash/JetBrains-'"${trash_date-}" \
command mkdir -p "${HOME-}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' && command mv -i "${HOME-}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' "${HOME-}"'/.Trash/Carthage-'"${trash_date-}" \
command mkdir -p "${HOME-}"'/Library/Caches/Homebrew/downloads' && command mv -i "${HOME-}"'/Library/Caches/Homebrew/downloads' "${HOME-}"'/.Trash/Homebrew-'"${trash_date-}" \
command -v brew >/dev/null 2>&1 && command brew cleanup --prune=all --verbose; { set +o errexit; set +o nounset; set +o xtrace; unset -- trash_developer; unset -- trash_date; } 2>/dev/null; printf '\n\n'; printf '\360\237%s\232\256  data successfully trashed\n' "${trash_developer-}"
```

## delete

`rm -ri /directory #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#securely-remove-path-force)<br/>
`rm  -i /document.txt # -i` stands for interactive

### empty directories

make a list of empty folders inside and beneath current directory **`.`** ([via](https://unix.stackexchange.com/a/46326))<br/>
`find -- . -type d -empty -print`<br/>
if satisfied with the results being lost and gone forever, execute:<br/>
`find -- . -type d -empty -delete`

### compare two folders

`diff --recursive /path/to/folder1 /path/to/folder2` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#compare-two-folders)

### purge memory cache

`sudo purge` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#purge-memory-cache)
