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
  - [add](#add-1)
    - [testing](#testing)
- [list everything recursively in a directory](#list-everything-recursively-in-a-directory)
  - [with full paths](#with-full-paths)
    - [and metadata](#and-metadata)
    - [lines, words, characters](#lines-words-characters)
- [search](#search)
  - [`grep`](#grep)
  - [locate all](#locate-all)
- [PATH](#path)
  - [entries](#entries)
    - [macOS](#macos)
    - [Linux](#linux)
- [text editing](#text-editing)
  - [export output](#export-output)
    - [sort](#sort)
  - [EOL and EOF encoding](#eol-and-eof-encoding)
- [make invisible](#make-invisible)
- [create an alias](#create-an-alias)
- [launch services](#launch-services)
  - [reset](#reset)
  - [repair website disk permissions](#repair-website-disk-permissions)
    - [date modified modify](#date-modified-modify)
- [C, C++](#c-c)
  - [flags](#flags)
    - [C++ features before wide support](#c-features-before-wide-support)
  - [apply `clang-format` recursively](#apply-clang-format-recursively)
  - [run `cpplint` recursively](#run-cpplint-recursively)
  - [run `cppcheck` recursively](#run-cppcheck-recursively)
  - [compile all files of type .𝑥 in a directory](#compile-all-files-of-type-𝑥-in-a-directory)
    - [C](#c)
    - [C++](#c)
    - [Clang](#clang)
- [Gatekeeper](#gatekeeper)
- [Git](#git)
  - [`init` via GitHub](#init-via-github)
  - [`add`](#add)
  - [`diff`](#diff)
  - [`commit`](#commit)
    - [with subject and body](#with-subject-and-body)
    - [in the past](#in-the-past)
  - [`config`](#config)
    - [editor](#editor)
  - [`tag`](#tag)
- [Numbers](#numbers)
  - [Affixes](#affixes)
- [Operating system](#operating-system)
  - [Identify](#identify)
- [parameter expansion](#parameter-expansion)
- [redirection](#redirection)
- [rename files](#rename-files)
- [split enormous files into something manageable](#split-enormous-files-into-something-manageable)
- [SSH](#ssh)
  - [`ls` on Windows](#ls-on-windows)
- [variables](#variables)
- [wget](#wget)
- [WiFi](#wifi)
  - [Windows password](#windows-password)
  - [macOS password](#macos-password)
- [Xcode](#xcode)
  - [signing](#signing)
- [housekeeping](#housekeeping)
  - [Docker](#docker)
  - [Flutter](#flutter)
  - [Homebrew](#homebrew-1)
  - [npm](#npm)
  - [RubyGems](#rubygems)
  - [Xcode, JetBrains, Carthage](#xcode-jetbrains-carthage)
- [delete](#delete)
  - [empty directories](#empty-directories)
  - [compare two folders](#compare-two-folders)
  - [purge memory cache](#purge-memory-cache)

<!-- /TOC -->

## copy, paste, return

```zsh
update=1 && clear && printf '                 .___       __\n __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n' &&
printf '\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n a Lucas Larson production\n\n' && sleep 1 && \
printf '\n\xf0\x9f\x93\xa1 verifying network connectivity...\n' && sleep 0.5 && (ping -q -i1 -c1 one.one.one.one &>/dev/null && ping -q -i1 -c1 8.8.8.8 &>/dev/null) || (printf 'No internet connection was detected.\nAborting update.\n' && return $update) && \
printf '\xf0\x9f\x8d\xba checking for Homebrew updates...\n' && brew update && brew upgrade && brew upgrade --cask && xcrun simctl delete unavailable && command -v omz >/dev/null 2>&1 && ( omz update ) && rustup update && npm install npm --global && npm update --global --verbose && apm upgrade --no-confirm && gem update --system && gem update && rbenv rehash && \
printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n' && python -m pip install --upgrade pip && \
printf '\n\xf0\x9f\x90\x8d generating list of outdated Python packages...\n' && pip list --outdated --format freeze | grep --invert-match '^\-e' | cut --delimiter = --fields 1 | xargs -n1 pip install --upgrade && \
printf '\n\xf0\x9f\x90\x8d upgrading all Python packages...\n' && pip install --upgrade $(pip freeze | cut --delimiter '=' --fields 1) && pyenv rehash && . ~/.${SHELL##*/}rc && rehash && unset update && \
printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "$update" && exec -l "${SHELL##*/}"
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
`pod update && #` [via](https://web.archive.org/web/20190719112335id_/https:/guides.cocoapods.org/using/pod-install-vs-update.html#pod-update) `\`<br/>
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
`printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "$update" && #` [via](https://stackoverflow.com/a/30762087), [via](https://stackoverflow.com/a/602924), [via](https://github.com/koalaman/shellcheck/wiki/SC2059/0c9cfe7e8811d3cafae8df60f41849ef7d17e296#problematic-code) `\`<br/>
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

Track changes to which applications are installed without syncing them. The instructions are Bash-compatible and refer to this document for instructions on regenerating the list.

```zsh
saveApplications=1 && mkdir --parents "$DOTFILES"/\!=Mackup && mkdir --parents /Applications && cd /Applications && filename="$DOTFILES"/\!=Mackup/:Applications && touch "$filename" && pwd > "$filename" && date '+%Y-%m-%d' >> "$filename" && printf '—————————————\n' >> "$filename" && ls -F1 >> "$filename" && cd "$DOTFILES" && mackup backup --force --root && \
git fetch --all && git submodule update --init --recursive --remote && git diff "$filename" && unset filename && saveApplications=$filename && printf '\n\n\xe2%s\x9c%s\x85 done!\n\n' "$filename" "$saveApplications"
```

On Alpine Linux, generate a list of installed packages with:<br/>
`apk -vv info|sort #` [via](https://wiki.alpinelinux.org/wiki/Special:PermanentLink/10079#Listing_installed_packages)

##### Homebrew

```zsh
listBrew="$DOTFILES/!=Mackup/brew list --formula --verbose" && touch "$listBrew" && printf 'brew list --formula --verbose\n' > "$listBrew" && date '+%Y-%m-%d' >> "$listBrew" && printf '—————————————————————————————\n' >> "$listBrew" && brew list --formula --verbose >> "$listBrew" && unset listBrew && printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "$listBrew"
```

###### Cask

```zsh
listBrewCask="$DOTFILES"/!=Mackup/brew\ cask\ list && touch "$listBrewCask" && printf 'brew cask list\n—————————————\n' > "$listBrewCask" && brew cask list >> "$listBrewCask" && unset listBrewCask && printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "$listBrewCask"
```

##### MANPATH

```zsh
saveManpath=1 && mkdir --parents "$DOTFILES"/\!=Mackup && filename="$DOTFILES"/\!=Mackup/manpath && touch "$filename" && printf '# \x24manpath\xe2\x80\x99s contents\n# ' > "$filename" && date '+%Y-%m-%d' >> "$filename" && printf '# ———————————————————————\n' >> "$filename" && <<<${(F)manpath} >> "$filename" && cd "$DOTFILES" && \
mackup backup --force --root && git fetch --all --verbose && git submodule update --init --recursive && git status && git diff "$filename" && unset filename && saveManpath="$filename" && printf '\n\n\xe2%s\x9c%s\x85 done!\n\n' "$filename" "$saveManpath"
```

###### man pages

Section description

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

```zsh
pip list && mkdir --parents "$DOTFILES"/\!=Mackup && printf 'pip packages installed ' > "$DOTFILES"/\!=Mackup/pip && date '+%Y-%m-%d' >> "$DOTFILES"/\!=Mackup/pip && printf '—————————————————————————————————\n' >> "$DOTFILES"/\!=Mackup/pip && pip list >> "$DOTFILES"/\!=Mackup/pip && cd "$DOTFILES" && \
mackup backup --force --root && git fetch --all --verbose && git submodule update --init --recursive && git status && git diff \!=Mackup/pip && printf '\n\n\xe2\x9c\x85 done\x21\n\n'
```

## apk

### add

#### testing

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

for example, locate all JPEG files<br/>
`locate -i *.jpg #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#search-via-locate); see also [§ grep](#grep)

## PATH

### entries

#### macOS

`<<<${(F)path}` # [via](https://codegolf.stackexchange.com/a/96471)

#### Linux

```zsh
pathSave=1 && mkdir --parents "$DOTFILES"/\!=Mackup && cd "$DOTFILES"/\!=Mackup && printf 'path\n' > path && date '+%Y-%m-%d' >> path && printf 'automagically generated' >> path && printf '\n———————————————————————\n' >> path && <<<${(F)path} >> path && git fetch --all --verbose && git submodule update --init --recursive && git status && git diff path && printf '\n\n\xe2\x9c\x85 done\x21\n\n' && pathSave=0
```

## text editing

### export output

`printf 'First Name\n' > ExampleFileWithGivenName.txt` # create a text file with “First Name” and a new line<br/>
`printf 'Other First Name\n'` **>** `ExampleFileWithGivenName.txt` # the “`>`” *overwrites* the existing file<br/>
`printf "Last Name\n"` **>>** `ExampleFileWithGivenName.txt` # the “`>>`” *appends* to the existing document

#### sort

`env > example.txt` # save an unordered list of `env` variables<br/>
`env | sort > example.txt` # [via](https://howtogeek.com/439199/15-special-characters-you-need-to-know-for-bash) save the variables in an alphabetically ordered list

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

### repair website disk permissions

`find -- /path/to/your/wordpress -type d -exec chmod 755 {} \; && \`<br/>
`find -- /path/to/your/wordpress -type f -exec chmod 644 {} \; #` [via](https://wordpress.org/support/article/hardening-wordpress/#changing-file-permissions)

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
`program="clang-format" && if ! command -v "$program" >/dev/null 2>&1; then printf '\nerror: no %s installation detected;\nskipping code\xc2\xa0formatting\n' "$program" && return 1; fi; \
clangformat=${1:-2} && printf '\n%s\n\n' "$("$program" --version)" && sleep 1 && printf 'applying %s to all applicable files in %s...\n' "$program" "${PWD##*/}" && sleep 1 && printf 'setting \x60IndentWidth\x60 to %s\n\n\n' "$clangformat" && sleep 1 && find -- * -type f \( \
-iname '*.c' -or -iname '*.c++' -or -iname '*.cc' -or -iname '*.cp' -or -iname '*.cpp' -or -iname '*.cxx' -or -iname '*.h' -or -iname '*.h++' -or -iname '*.hh' -or -iname '*.hp' -or -iname '*.hpp' -or -iname '*.hxx' -or \
-iname '*.i' -or -iname '*.ii' -or -iname '*.java' -or -iname '*.js' -or -iname '*.m' -or -iname '*.mi' -or -iname '*.mii' -or -iname '*.mm' -or -iname '*.tcc' -or -iname '*.tpp' -or -iname '*.txx' \) -exec "$program" -i -style "{IndentWidth: $clangformat}" --verbose {} \; && printf '\n\n\xe2\x9c\x85 done\x21\n\n'`

### run `cpplint` recursively

`cpplint --verbose=0 --linelength=79 --recursive --extensions=c++,cc,cp,cpp,cxx,h,h++,hh,hp,hpp,hxx . >> cpplint.txt`

### run `cppcheck` recursively

`cppcheck --force -I $CPATH . >> cppcheck.txt`

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

### `add`

[via](https://stackoverflow.com/a/15011313)
| content to add | git command |
|------------------------|----|
| modified files only | `git add --updated || git add -u` |
| everything except deleted files | `git add .` |
| everything | `git add --all || git add -A` |

### `diff`

more detailed `git diff` and how I once found an LF‑to‑CRLF‑only difference<br/>
`git diff --raw`

### `commit`

#### with subject and body

`git commit --message 'subject' --message 'body' #` [via](https://stackoverflow.com/a/40506149)

#### in the past

to backdate a commit:<br/>
`GIT_TIME='`**2000-01-02T15:04:05 -0500**`' GIT_AUTHOR_DATE=$GIT_TIME GIT_COMMITTER_DATE=$GIT_TIME git commit --message 'add modifications made at 3:04:05pm EST on January 2, 2000' #` [via](https://stackoverflow.com/questions/3895453/how-do-i-make-a-git-commit-in-the-past#comment97787061_3896112)

### `config`

#### editor

Vim<br/>
`git config --global core.editor /usr/local/bin/vim`<br/>
Atom [via](https://stackoverflow.com/a/31389989)<br/>
`git config --global core.editor "atom --wait"`

### `tag`

`git tag v𝑖.𝑗.𝑘 #` where 𝑖, 𝑗, and 𝑘 are non-negative integers representing [<abbr title="semantic versioning">semver</abbr>](https://github.com/semver/semver/blob/8b2e8eec394948632957639dfa99fc7ec6286911/semver.md#summary) major, minor, and patch releases<br/>
`git push origin v𝑖.𝑗.𝑘 #` push the unannotated tag [via](https://stackoverflow.com/a/5195913)

## Numbers

### Affixes

| Definition  | Prefix | Suffix            |
|-------------|--------|-------------------|
| binary      | `0b`𝑛 | 𝑛<sub>`2`</sub>  |
| octal       | `0o`𝑛 | 𝑛<sub>`8`</sub>  |
| decimal     | `0d`𝑛 | 𝑛<sub>`10`</sub> |
| hexadecimal | `0x`𝑛 | 𝑛<sub>`16`</sub> |

## Operating system

### Identify

`command -v uname >/dev/null 2>&1 && \`<br/>
`printf '\n\x60uname -a\x60:\n%s\n\n' "$(uname -a)"; \`<br/>
`command -v sw_vers >/dev/null 2>&1 && #` [via](https://apple.stackexchange.com/a/368244) `\`<br/>
`printf '\n\x60sw_vers\x60:\n%s\n\n' "$(sw_vers)"; \`<br/>
`command -v lsb_release >/dev/null 2>&1 && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-from-the-command-line) `\`<br/>
`printf '\n\x60lsb_release --all\x60:\n%s\n\n' "$(lsb_release --all)"; \`<br/>
`[ -r /etc/os-release ] && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-using-the-etcos-release-file) `\`<br/>
`printf '\x60cat /etc/os-release\x60:\n%s\n\n' "$(cat /etc/os-release)"`

## parameter expansion

[via](https://opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)
|                        | *parameter* Set and Not Null | *parameter* Set But Null | *parameter* Unset |
|------------------------|------------------------------|--------------------------|-------------------|
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

| syntax        | meaning                                         | POSIX compliance |
| -------       | -----------------------------                   | --               |
| `>file`       | redirect `stdout` to `file`                     | ✅                |
| `1>file`      | redirect `stdout` to `file`                     | ✅                |
| `2>file`      | redirect `stderr` to `file`                     | ✅                |
| `>file 2>&1`  | redirect `stdout` and `stderr` to `file`        | ✅                |
| `&>file`      | redirect `stdout` and `stderr` to `file` (Bash) | 🚫               |
| `>>file 2>&1` | append `stdout` and `stderr` to `file`          | ✅                |
| `&>>/file`    | append `stdout` and `stderr` to `file` (Bash)   | 🚫               |

## rename files

`brew install --upgrade rename && #` [via](https://stackoverflow.com/a/31694356) `\`<br/>
`rename --dry-run --verbose --subst searchword replaceword *`

## split enormous files into something manageable

if your example.csv has too many rows ([via](https://web.archive.org/web/20181210131347/domains-index.com/best-way-view-edit-large-csv-files/#post-12141))<br/>
`split --lines 2000 example.csv; for i in *; do mv "$i" "$i.csv"; done`

## SSH

`ssh username@example.com`

### `ls` on Windows

`dir` # [via](https://stackoverflow.com/a/58740114)

## variables

`$PWD` # the name of the current directory and its entire path
`${PWD##*/}` # [via](https://stackoverflow.com/a/1371283) the name of only the current directory

## wget

`wgetServer=`'**example.com**' `&& (wget --mirror --continue --verbose --append-output=$wgetServer.log --execute robots=off --restrict-file-names=nocontrol --timestamping --debug --recursive --show-progress http://$wgetServer || wget --continue  http://$wgetServer) && unset wgetServer || unset wgetServer`

## WiFi

### Windows password

`netsh wlan show profile WiFi-name key=clear #` [via](https://reddit.com/r/LifeProTips/comments/d5vknk/lpt_if_you_ever_forget_your_wifi_password_or_you/)

### macOS password

`security find-generic-password -wa ExampleNetwork #` [via](https://www.labnol.org/software/find-wi-fi-network-password/28949/)

## Xcode

### signing

`PRODUCT_BUNDLE_IDENTIFIER = net.LucasLarson.$(PRODUCT_NAME:rfc1034identifier);`<br/>
`PRODUCT_NAME = $(PROJECT_NAME);`<br/>
`DEVELOPMENT_TEAM = Z25963JBNP;`<br/>
`DevelopmentTeam = Z25963JBNP;`

## Zsh

### .zshrc

#### troubleshooting

Add `zmodload zsh/zprof` at the top of `~/.zshrc` and `zprof` at the bottom of
it. Restart restart to get a profile of startup time usage.&nbsp;[via](https://web.archive.org/web/20210112072135id_/reddit.com/r/zsh/comments/kums6q/zsh_very_slow_to_open_how_to_debug/gisz7nc/)

## housekeeping

### Docker

`docker system prune --all #` [via](https://news.ycombinator.com/item?id=25547876#25547876)

### Flutter

`cd ~/Code/Flutter && git pull && flutter upgrade && flutter precache && flutter doctor --verbose`

### Homebrew

`brew doctor --debug --verbose && \`<br/>
`brew cleanup --debug --verbose && #` [via](https://stackoverflow.com/a/41030599) `\`<br/>
`brew audit cask --strict --token-conflicts`

### npm

`npm doctor && #` creates empty `node_modules` directories `\`<br/>
`find -- node_modules -empty -type d -delete #` deletes them [via](https://perma.cc/YNL2-FY3Z)

### RubyGems

`gem cleanup --verbose`

### Xcode, JetBrains, Carthage

```zsh
trashDeveloper=1 && sleep 0.25 && \
mkdir --parents "${HOME}/Library/Developer/Xcode/DerivedData" && mv "${HOME}/Library/Developer/Xcode/DerivedData" "${HOME}/.Trash/Xcode-${RANDOM}" && \
mkdir --parents "${HOME}/Library/Developer/Xcode/UserData/IB Support" && mv "${HOME}/Library/Developer/Xcode/UserData/IB Support" "${HOME}/.Trash/Xcode⁄UserData⁄IB Support-${RANDOM}" && \
mkdir --parents "${HOME}/Library/Caches/JetBrains" && mv "${HOME}/Library/Caches/JetBrains" "${HOME}/.Trash/JetBrains-${RANDOM}" && \
mkdir --parents "${HOME}/Library/Caches/org.carthage.CarthageKit/DerivedData" && mv "${HOME}/Library/Caches/org.carthage.CarthageKit/DerivedData" "${HOME}/.Trash/Carthage-${RANDOM}" && \
unset trashDeveloper && printf '\n\n\xf0\x9f%s\x9a\xae data successfully trashed\n\n' "${trashDeveloper:-"$(printf '')"}"
```

## delete

`rm -ri /directory #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#securely-remove-path-force)<br/>
`rm  -i /document.txt # -i` stands for <u>i</u>nteractive

### empty directories

make a list of empty folders inside and beneath current directory **`.`** ([via](https://unix.stackexchange.com/a/46326))<br/>
`find -- . -type d -empty -print`<br/>
if satisfied with the results being lost and gone forever, execute:<br/>
`find -- . -type d -empty -delete`

### compare two folders

`diff --recursive /path/to/folder1 /path/to/folder2` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#compare-two-folders)

### purge memory cache

`sudo purge` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#purge-memory-cache)
