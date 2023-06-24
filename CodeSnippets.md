# Code snippets

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [dotfiles](#dotfiles)
  - [add](#add)
    - [manual](#manual)
      - [lists](#lists)
        - [applications](#applications)
      - [Homebrew](#homebrew)
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
- [case-naming conventions](#case-naming-conventions)
- [C, C++](#c-c)
  - [flags](#flags)
    - [C++ features before wide support](#c-features-before-wide-support)
  - [run `cpplint` recursively](#run-cpplint-recursively)
  - [run `cppcheck` recursively](#run-cppcheck-recursively)
  - [compile all files of type .𝑥 in a directory](#compile-all-files-of-type-𝑥-in-a-directory)
    - [C](#c)
    - [C++](#c-1)
    - [Clang](#clang)
- [Gatekeeper](#gatekeeper)
- [Git](#git)
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
  - [initialization](#initialization)
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

## dotfiles

### add

#### manual

to add dotfiles of the variety [Mackup](https://github.com/lra/mackup) might’ve but hasn’t yet:

```shell
# make `~/Desktop/.example.txt` part of the dotfiles repository
add="${HOME%/}"'/Desktop/.example.txt'
command mv -- "${add-}" "${DOTFILES-}"'/directory_where_it_should_go_if_any/'"${add##*/}"
command ln -s -- "${DOTFILES-}"'/directory_where_it_should_go_if_any/'"${add##*/}" "${HOME%/}"'/directory_where_it_should_go_if_any/'"${add##*/}"
unset -v -- add
```

##### lists

###### applications

```shell
command find -- \
  /System/Applications \
  /Applications \
  -maxdepth 3 \
  -name '*.app' 2>/dev/null |
  command sed -e 's/.*\/\(.*\)\.app/\1/' |
  LC_ALL='C' command sort -d -f
```

On Alpine Linux, generate a list of installed packages with:<br>
`command apk --verbose --verbose info | LC_ALL='C' command sort #` [via](https://wiki.alpinelinux.org/wiki/Special:PermanentLink/10079#Listing_installed_packages)

##### Homebrew

```shell
command brew list -1
```

##### MANPATH

```shell
printf '%s\n' "${MANPATH-}" | sed -e 'y/:/\n/'
```

###### man pages

Definintions of the numbers that follow `man` commands ([via](https://web.archive.org/web/20200627082020id_/manpages.ubuntu.com/cgi-bin/search.py?q=man&titles=Title#distroAndSection))

| section | contents                                                 |
| :-----: | -------------------------------------------------------- |
| `1`     | Executable programs or shell commands                    |
| `2`     | System calls (functions provided by the kernel)          |
| `3`     | Library calls (functions within program libraries)       |
| `4`     | Special files (usually found in `/dev`)                  |
| `5`     | File formats and conventions, `/etc/passwd`, for example |
| `6`     | Games                                                    |
| `7`     | Miscellaneous (including macro packages and conventions) |
| `8`     | System administration commands (usually only for `root`) |

##### pip packages

```shell
{ command pip list || command pip3 list; } 2>/dev/null
```

## apk

### testing

`apk add foo #` unavailable? `\`<br>
`#` then try `\`<br>
`apk add foo@testing #` [via](https://web.archive.org/web/20201014175951id_/stackoverrun.com/ja/q/12834672#text_a46821207)

## list everything recursively in a directory

### with full paths

`find -- .` # [via](https://www.cyberciti.biz/faq/how-to-list-directories-in-linux-unix-recursively/)

#### and metadata

`find -- . -ls`

#### lines, words, characters

in, for example, a C++ project directory, measuring only `.cpp` and `.hpp`
files. [via](https://web.archive.org/web/0id_/github.com/bryceco/GoMap/issues/495#issuecomment-780111175)

```sh
command find -- . '(' -name '*.cpp' -o -name '*.hpp' ')' -print |
  command xargs wc |
  LC_ALL='C' command sort -n
```

## search

### `grep`

search for the word “example” inside the current directory which is “.”<br>
`grep -i -n -r 'example' .`

### locate all

for example, locate all JPEG files in the current directory `.` and below:<br>
`command find -- . -type f '(' -name '*.jpg' -o -name '*.JPEG' -o -name '*.JPG' -o -name '*.jpeg' ')'`

## PATH

```shell
printf '%s\n' "${PATH-}" | sed -e 'y/:/\n/'
```

### executables

`print -l ${^path-}/*(-*N)` # [via](https://web.archive.org/web/20210206194844id_/grml.org/zsh/zsh-lovers#_unsorted_misc_examples)

## text editing

### export output

`printf 'First Name\n'` **>**`./ExampleFileWithGivenName.txt` # create a text file with “First Name” and a new line<br>
`printf 'Other First Name\n'` **>**`./ExampleFileWithGivenName.txt` # the “`>`” *overwrites* the existing file<br>
`printf 'Last Name\n'` **>>**`./ExampleFileWithGivenName.txt` # the “`>>`” *appends* to the existing document

#### sort

`command env >./example.txt` # save an unordered list of `env` variables<br>
`command env | LC_ALL='C' command sort >./example.txt` # [via](https://howtogeek.com/439199/15-special-characters-you-need-to-know-for-bash) save the variables in an alphabetically ordered list

### EOL and EOF encoding

find `(?<![\r\n])$(?![\r\n])` # [via](https://stackoverflow.com/a/34958727)<br>
replace `\r\n`

## make invisible

`chflags -hvv hidden example.txt`<br>
`-h` for symbolic links, if applicable, but not their targets<br>
`-v`₁ for verbose<br>
`-v`₂ for printing the old and new flags in octal to `stdout`

## create an alias

`ln -s` (link, symbolic) uses arguments just like `cp existing new`
([via](https://reddit.com/comments/1qt0z#t1_c1qtge)):

```shell
ln -s existing_file shortcut_to_file
```

## launch services

### reset

remove bogus entries from Finder’s “Open With” menu ([via](https://github.com/mathiasbynens/dotfiles/blob/e42090bf49f860283951041709163653c8a2c522/.aliases#L69-L70))<br>
`/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -seed -r -domain local -domain system -domain user && killall Finder`

### repair site disk permissions

[via](https://wordpress.org/support/article/hardening-wordpress/#changing-file-permissions)

```shell
command find -- . ! -path '*/.*' -type d -exec chmod -- 755 '{}' '+'
command find -- . ! -path '*/.*' -type f -exec chmod -- 644 '{}' '+'
```

#### date modified modify

`touch -t 2003040500 file.txt` # date modified → 2020-03-04 5:00am

## case-naming conventions

| Naming Convention    | Format               |
| -------------------- | -------------------- |
| Camel Case           | camelCase            |
| Camel Snake Case     | camel_Snake_Case     |
| Capital Case         | Capital Case         |
| Cobol Case           | COBOL-CASE           |
| Constant Case        | CONSTANT_CASE        |
| Dash Case            | dash-case            |
| Dot Case             | dot.case             |
| Dromedary Case       | dromedaryCase        |
| Flat Case            | flatcase             |
| HTTP Header Case     | HTTP-Header-Case     |
| Kebab Case           | kebab-case           |
| Lisp Case            | lisp-case            |
| Lower Camel Case     | lowerCamelCase       |
| Lower Case           | lower case           |
| Macro Case           | MACRO_CASE           |
| Mixed Case           | Mixed Case           |
| Pascal Case          | PascalCase           |
| Pascal Snake Case    | Pascal_Snake_Case    |
| Pothole Case         | pothole_case         |
| Screaming Kebab Case | SCREAMING-KEBAB-CASE |
| Screaming Snake      | SCREAMING_SNAKE_CASE |
| Sentence case        | Sentence case        |
| Snake Case           | snake_case           |
| Spinal Case          | spinal-case          |
| Studly Case          | StudlyCase           |
| Title Case           | Title Case           |
| Train Case           | Train-Case           |
| Upper Camel Case     | UpperCamelCase       |
| Upper Case           | UPPER CASE           |

## C, C++

### flags

`-Wall -Wextra -pedantic`<br>
`#ifdef __APPLE__`<br>
    `-Weverything <!--` do not use ([via](https://web.archive.org/web/20190926015534id_/quuxplusone.github.io/blog/2018/12/06/dont-use-weverything/#for-example-if-you-want-to-see-a)) `-->`<br>
`#endif`<br>
`-Woverriding-method-mismatch -Weffc++ -Wcall-to-pure-virtual-from-ctor-dtor -Wmemset-transposed-args -Wreturn-std-move -Wsizeof-pointer-div -Wdefaulted-function-deleted` # [via](https://github.com/jonreid/XcodeWarnings/issues/8#partial-discussion-header)<br>
`-lstdc++ #` [via](https://web.archive.org/web/20200517174250id_/unspecified.wordpress.com/2009/03/15/linking-c-code-with-gcc/#post-54) but this might – or might not – be helpful on macOS using gcc or g++

#### C++ features before wide support

for example, C++17’s `<filesystem>`<br>
`-lstdc++fs`

### run `cpplint` recursively

`cpplint --verbose=0 --linelength=79 --recursive --extensions=c++,cc,cp,cpp,cxx,h,h++,hh,hp,hpp,hxx . >>./cpplint.txt`

### run `cppcheck` recursively

`cppcheck --force -I $CPATH . >>./cppcheck.txt`

### compile all files of type .𝑥 in a directory

#### C

[via](https://stackoverflow.com/q/32029445), [via](https://stackoverflow.com/q/33662375)<br>
`gcc -std=c89 --verbose -save-temps -v -Wall -Wextra -pedantic *.c`

#### C++

`g++ -std=c++2a --verbose -Wall -Wextra -pedantic -save-temps -v -pthread -fgnu-tm -lm -latomic -lstdc++ *.cpp`

#### Clang

`clang++ -std=c++2a --verbose -Wall -Wextra -pedantic -v -lm -lstdc++ -pthread -save-temps *.cpp`

## Gatekeeper

do not disable it, because that would allow you to install any software, even if unsigned, even if malicious:<br>
`sudo spctl --master-disable #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/bd25a136655e63fcb7f3462a8dc7105f30093e54/README.md#manage-gatekeeper)

## Git

### `git add`

[via](https://stackoverflow.com/a/15011313)

| content to add                  | git command                         |
| ------------------------------- | ----------------------------------- |
| modified files only             | `git add --updated` or `git add -u` |
| everything except deleted files | `git add .`                         |
| everything                      | `git add --all` or `git add -A`     |

### `git diff`

more detailed `git diff` and how I once found an LF‑to‑CRLF‑only difference<br>
`git diff --raw`

### `git commit`

#### with subject and body

`git commit --message='subject' --message='body' #` [via](https://stackoverflow.com/a/40506149)

#### in the past

to backdate a commit:<br>
`GIT_TIME='`**2000-01-02T15:04:05 -0500**`' GIT_AUTHOR_DATE=$GIT_TIME GIT_COMMITTER_DATE=$GIT_TIME git commit --message='add modifications made at 3:04:05pm EST on January 2, 2000' #` [via](https://stackoverflow.com/questions/3895453/how-do-i-make-a-git-commit-in-the-past#comment97787061_3896112)

### `git config`

#### editor

Vim<br>
`git config --global core.editor /usr/local/bin/vim`<br>
Visual Studio Code<br>
`git config --global core.editor "code --wait"`

### `git tag`

`git tag v𝑖.𝑗.𝑘 #` where 𝑖, 𝑗, and 𝑘 are non-negative integers representing [SemVer](https://github.com/semver/semver/blob/8b2e8eec394948632957639dfa99fc7ec6286911/semver.md#summary) (semantic versioning) major, minor, and patch releases<br>
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

`printf '\n\140uname -a\140:\n%s\n\n' "$(uname -a)"; \`<br>
`command -v -- sw_vers >/dev/null 2>&1 && #` [via](https://apple.stackexchange.com/a/368244) `\`<br>
`printf '\n\140sw_vers\140:\n%s\n\n' "$(sw_vers)"; \`<br>
`command -v -- lsb_release >/dev/null 2>&1 && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-from-the-command-line) `\`<br>
`printf '\n\140lsb_release --all\140:\n%s\n\n' "$(lsb_release --all)"; \`<br>
`[ -r /etc/os-release ] && #` [via](https://web.archive.org/web/20201023154958id_/linuxize.com/post/how-to-check-your-debian-version/#checking-debian-version-using-the-etcos-release-file) `\`<br>
`printf '\140cat /etc/os-release\140:\n%s\n\n' "$(cat /etc/os-release)"`

## parameter expansion

[via](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)

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
| ------------- | ---------------------------------------- | :--------------: |
| `>file`       | redirect `stdout` to `file`              | ✅                |
| `1>file`      | redirect `stdout` to `file`              | ✅                |
| `2>file`      | redirect `stderr` to `file`              | ✅                |
| `>file 2>&1`  | redirect `stdout` and `stderr` to `file` | ✅                |
| `&>file`      | redirect `stdout` and `stderr` to `file` | 🚫                |
| `>>file 2>&1` | append `stdout` and `stderr` to `file`   | ✅                |
| `&>>/file`    | append `stdout` and `stderr` to `file`   | 🚫                |

## rename files

`brew install --upgrade rename && #` [via](https://stackoverflow.com/a/31694356) `\`<br>
`rename --dry-run --verbose --subst searchword replaceword *`

### replace

recursively replace each file’s first line that begins with `#!`, and which later contains `/bin/bash`, `/bin/sh`, or `/bin/ash`, with `#!/usr/bin/env zsh` ([via](https://stackoverflow.com/a/11458836))

```shell
find -- . -type f -exec sed \
  -e '/^#!.*\/bin\/b\{0,1\}a\{0,1\}sh$/ {' \
  -e 's//#!\/usr\/bin\/env zsh/' \
  -e ':a' \
  -e '$! N' \
  -e '$! b a' \
  -e '}' \
  '{}' ';'
```

## split enormous files into something manageable

if your example.csv has too many rows ([via](https://web.archive.org/web/20181210131347/domains-index.com/best-way-view-edit-large-csv-files/#post-12141))<br>
`split -l 2000 example.csv; for i in *; do mv "$i" "$i.csv"; done`

## SSH

`ssh username@example.com`

### `ls` on Windows

`dir` # [via](https://stackoverflow.com/a/58740114)

## variables

`$PWD` # the name of the current directory and its entire path<br>
`${PWD##*/}` # [via](https://stackoverflow.com/a/1371283) the name of only the current directory

## wget

`wget_server='`**example.com**`'; if command -v -- wget2 >/dev/null 2>&1; then utility='wget2'; else utility='wget'; fi; \
command "${utility-}" --level=0 --mirror --continue --verbose \
--append-output=./"${wget_server-}".log --execute robots=off --restrict-file-names=nocontrol --timestamping --debug --recursive --progress=bar --no-check-certificate --random-wait \
--referer=https://"${wget_server-}" --adjust-extension --page-requisites --convert-links --server-response \
https://"${wget_server-}"; unset -v -- wget_server utility`

## Wi-Fi

### Windows password

`netsh wlan show profile WiFi-name key=clear #` [via](https://redd.it/d5vknk)

### macOS password

`security find-generic-password -wa ExampleNetwork #` [via](https://labnol.org/software/find-wi-fi-network-password/28949)

## Xcode

### signing

`PRODUCT_BUNDLE_IDENTIFIER = net.LucasLarson.$(PRODUCT_NAME:rfc1034identifier);`<br>
`PRODUCT_NAME = $(PROJECT_NAME) || $(PRODUCT_NAME:c99extidentifier) || $(TARGET_NAME)`<br>
`DEVELOPMENT_TEAM = "$(DEVELOPMENT_TEAM)";`<br>
`DevelopmentTeam = "$(DEVELOPMENT_TEAM)";`<br>
`WARNING_CFLAGS = $(inherited) $(WAX_ANALYZER_FLAGS)`

Search the `.pbxproj` file for
`project|product|development|example|public|sample|organization|target|ident|dir`.

## Zsh

### array types

`<<<${(t)path-} #` [via](https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path)

### initialization

Zsh sources in order loaded:

1. `/etc/zshenv`
1. `~/.zshenv`
1. `/etc/zprofile`
1. `~/.zprofile`
1. `/etc/zshrc`
1. `~/.zshrc`
1. `/etc/zlogin`
1. `~/.zlogin`
1. `/etc/zlogout`
1. `~/.zlogout`

### troubleshooting

Add `zmodload zsh/zprof` at the top of `~/.zshrc` and `zprof` at the bottom of
it. Restart restart to get a profile of startup time usage.&nbsp;[via](https://web.archive.org/web/20210112072135id_/reddit.com/r/zsh/comments/kums6q/zsh_very_slow_to_open_how_to_debug/gisz7nc/)

## housekeeping

### docker

`docker system prune --all #` [via](https://news.ycombinator.com/item?id=25547876#25547876)

### brew

`brew doctor --debug --verbose && \`<br>
`brew cleanup --debug --verbose && #` [via](https://stackoverflow.com/a/41030599) `\`<br>
`brew audit cask --strict --token-conflicts`

### npm

`npm audit fix && \`<br>
`npm doctor && #` creates empty `node_modules` directories `\`<br>
`find -- node_modules -links 2 -type d -delete #` deletes them

### gem

`gem cleanup --verbose`

### Xcode, JetBrains, Carthage, Homebrew

```shell
trash_developer='1'; command sleep 1; set -o xtrace; trash_date="$(command date -u -- '+%Y%m%d')"_"$(command awk -- 'BEGIN {srand(); print srand()}')" \
command mkdir -p -- "${HOME%/}"'/Library/Developer/Xcode/DerivedData' && command mv -- "${HOME%/}"'/Library/Developer/Xcode/DerivedData' "${HOME%/}"'/.Trash/Xcode-'"${trash_date-}" \
command mkdir -p -- "${HOME%/}"'/Library/Developer/Xcode/UserData/IB Support' && command mv -- "${HOME%/}"'/Library/Developer/Xcode/UserData/IB Support' "${HOME%/}"'/.Trash/Xcode⁄UserData⁄IB Support-'"${trash_date-}" \
command mkdir -p -- "${HOME%/}"'/Library/Caches/JetBrains' && command mv -- "${HOME%/}"'/Library/Caches/JetBrains' "${HOME%/}"'/.Trash/JetBrains-'"${trash_date-}" \
command mkdir -p -- "${HOME%/}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' && command mv -- "${HOME%/}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' "${HOME%/}"'/.Trash/Carthage-'"${trash_date-}" \
command mkdir -p -- "${HOME%/}"'/Library/Caches/Homebrew/downloads' && command mv -- "${HOME%/}"'/Library/Caches/Homebrew/downloads' "${HOME%/}"'/.Trash/Homebrew-'"${trash_date-}" \
command -v -- brew >/dev/null 2>&1 && { command brew autoremove --verbose; command brew cleanup --prune=all --verbose; }; { set +o xtrace; unset -v -- trash_developer; unset -v -- trash_date; } 2>/dev/null; printf '\n\n\360\237%s\232\256  data successfully trashed\n' "${trash_developer-}"
```

## delete

`rm -ri /directory #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#securely-remove-path-force)<br>
`rm  -i /document.txt # -i` stands for interactive

### empty directories

make a list of empty folders inside and beneath current directory **`.`** ([via](https://unix.stackexchange.com/a/46326))<br>
`find -- . -type d -links 2 -print`<br>
if satisfied with the results being lost and gone forever, execute:<br>
`find -- . -type d -links 2 -delete`

### compare two folders

`diff --recursive /path/to/folder1 /path/to/folder2` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#compare-two-folders)

### purge memory cache

`sudo purge` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#purge-memory-cache)
