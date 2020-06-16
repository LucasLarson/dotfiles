# Code snippets
<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [copy, paste, return](#copy-paste-return)
  - [detail](#detail)
- [Mackup](#mackup)
  - [add](#add)
    - [manual](#manual)
      - [lists](#lists)
        - [applications](#applications)
      - [Atom packages](#atom-packages)
      - [Homebrew](#homebrew)
        - [Cask](#cask)
      - [$MANPATH](#manpath)
      - [pip packages](#pip-packages)
- [search](#search)
  - [`grep`](#grep)
  - [locate all](#locate-all)
- [`$PATH`](#path)
  - [entries](#entries)
    - [macOS](#macos)
    - [Linux](#linux)
- [text editing](#text-editing)
  - [export output](#export-output)
- [make invisible](#make-invisible)
- [create an alias](#create-an-alias)
- [launch services](#launch-services)
  - [reset](#reset)
  - [repair website disk permissions](#repair-website-disk-permissions)
    - [date modified modify](#date-modified-modify)
  - [flags for C, C++](#flags-for-c-c)
    - [C++ features before wide support](#c-features-before-wide-support)
- [Gatekeeper](#gatekeeper)
- [Git](#git)
  - [`init` via GitHub](#init-via-github)
  - [`add`](#add)
  - [`diff`](#diff)
  - [`commit`](#commit)
    - [with subject *and* body](#with-subject-and-body)
    - [in the past](#in-the-past)
  - [`editor`](#editor)
  - [rename files](#rename-files)
  - [split enormous files into something manageable](#split-enormous-files-into-something-manageable)
- [SSH](#ssh)
  - [`ls` on Windows](#ls-on-windows)
- [wget](#wget)
- [WiFi](#wifi)
  - [password](#password)
    - [Windows](#windows)
    - [macOS](#macos-1)
- [Xcode](#xcode)
  - [signing](#signing)
  - [dependencies](#dependencies)
- [housekeeping](#housekeeping)
  - [Homebrew](#homebrew-1)
  - [npm](#npm)
  - [RubyGems](#rubygems)
  - [Flutter](#flutter)
  - [Xcode and JetBrains](#xcode-and-jetbrains)
- [delete](#delete)
  - [with confirmation first](#with-confirmation-first)
  - [without confirmation](#without-confirmation)
  - [empty directories](#empty-directories)
  - [compare two folders](#compare-two-folders)
  - [purge memory cache](#purge-memory-cache)

<!-- /TOC -->

## copy, paste, return
```bash
update=-1 && brew update && brew upgrade && brew cask upgrade && xcrun simctl delete unavailable && upgrade_oh_my_zsh && rustup update && npm install npm --global && npm update --global --verbose && apm upgrade --no-confirm && gem update --system && gem update && rbenv rehash && python -m pip install --upgrade pip && pip list --outdated --format freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install --upgrade && pip install --upgrade $(pip freeze | cut -d '=' -f 1) && pyenv rehash && source ~/.zshrc && unset update && printf '\n\n\xe2'$update'\x9c\x85 done\x21\n\n' && exec zsh
```
### detail
`xcode-select --install && \`<br/>
`xcrun simctl delete unavailable && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/d7406c3bb347af9fb1734885ed571117a5dbf90a/README.md#remove-all-unavailable-simulators) `\`<br/>
`brew update --debug --verbose && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/launchagents.md#periodic-homebrew-update-and-upgrade)`,` [via](https://stackoverflow.com/a/47664603) `\`<br/>
`brew upgrade && \`<br/>
`brew cask upgrade && #` [via](https://github.com/hisaac/hisaac.net/blob/8c63d51119fe2a0f05fa6c1c2a404d12256b0594/source/_posts/2018/2018-02-12-update-all-the-things.md#readme) `\`<br/>
`brew install mackup --head && #` 0.8.29 [2020-06-06](https://github.com/lra/mackup/blob/master/CHANGELOG.md#mackup-changelog) `\`<br/>
`mackup backup && # || mackup backup --force \`<br/>
`upgrade_oh_my_zsh && #` [via](https://github.com/robbyrussell/oh-my-zsh/blob/17f4cfca99398cb5511557b8515a17bf1bf2948a/README.md#manual-updates) `\`<br/>
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
    `| grep -v '^\-e' \`<br/>
    `| cut -d = -f 1 \`<br/>
    `| xargs -n1 pip install --upgrade && #` [via](https://stackoverflow.com/revisions/3452888/14) `\`<br/>
`pip install --upgrade $(pip freeze | cut -d '=' -f 1) && #` [via](https://web.archive.org/web/20200508173219id_/coderwall.com/p/quwaxa/update-all-installed-python-packages-with-pip#comment_29830) `\`<br/>
`pipenv shell &&` # [via](https://github.com/pypa/pipenv/blob/bfbe1304f63372a0eb7c1531590b51195db453ea/pipenv/core.py?instructions_while_running_pipenv_install#L1282) `\`<br/>
`pipenv install --dev && #` [via](https://stackoverflow.com/a/49867443) `\`<br/>
`rustup update && #` 1.44.0 [2020-06-04](https://github.com/rust-lang/rust/releases) `\`<br/>
`source ~/.zsh && \`<br/>
`brew install carthage --head && #` 0.34.0 [2019-10-21](https://github.com/Carthage/Carthage/releases) `\`<br/>
`carthage update --no-use-binaries && #` [via](https://stackoverflow.com/a/41526660) `\`<br/>
`brew install swiftgen --head && #`  6.1.0 [2019-01-29](https://github.com/SwiftGen/SwiftGen/releases) `\`<br/>
`swiftgen && \`<br/>
`brew install swiftlint --head && #` 0.39.2 [2020-04-03](https://github.com/realm/SwiftLint/releases) `\`<br/>
`swiftlint autocorrect && \`<br/>
`# git add . && git add -u || git add -A && #` [via](https://stackoverflow.com/a/15011313) `\`<br/>
`git gc && \`<br/>
`# gradle build --refresh-dependencies --warning-mode all && #` [via](https://stackoverflow.com/a/35374051) `\`<br/>
`printf '\n\n\xe2\x9c\x85 done\x21\n\n' && #` [via](https://stackoverflow.com/a/30762087), [via](https://stackoverflow.com/a/602924) `\`<br/>
`exec zsh #` note successful finish before restarting the shell

## Mackup
### add
#### manual
to add dotfiles, for example, of the variety [Mackup](https://github.com/lra/mackup) might’ve but hasn’t
`add='`**~/Desktop/example.txt**`' && cp ~/$add ~/Dropbox/Mackup/$add && mv ~/$add ~/.Trash && ln -s ~/Dropbox/Mackup/$add ~/$add`

##### lists
###### applications
Track changes to which applications are installed without syncing them. The instructions are bash-compatible and refer to this document for instructions on regenerating the list.
```bash
saveApplications=-1 && mkdir -p $DOTFILES/\!=Mackup && mkdir -p /Applications && cd /Applications && filename=$DOTFILES/\!=Mackup/:Applications && touch $filename && pwd > $filename && date '+%Y-%m-%d' >> $filename && printf '—————————————\n' >> $filename && ls -F1 >> $filename && cd $DOTFILES && mackup backup && git fetch && git submodule update --init --recursive && git status && git diff $filename && filename='' && saveApplications=$filename && printf '\n\n\xe2'$filename'\x9c'$saveApplications'\x85 done!\n\n'
```
##### Atom packages
```bash
apm list && mkdir -p ~/Dropbox/Mackup/\!=Mackup && printf 'Atom extensions ' > ~/Dropbox/Mackup/\!=Mackup/Atom && date '+%Y-%m-%d' >> ~/Dropbox/Mackup/\!=Mackup/Atom && printf '———————————————\n' >> ~/Dropbox/Mackup/\!=Mackup/Atom && apm list >> ~/Dropbox/Mackup/\!=Mackup/Atom && cd ~/Dropbox/Mackup && mackup backup && git fetch && git submodule update --init --recursive && git status && git diff \!=Mackup/Atom && printf '\n\n\xe2\x9c\x85 done\x21\n\n'
```
##### Homebrew
```bash
listBrew=$DOTFILES/!=Mackup/brew\ list\ --verbose && touch $listBrew && printf 'brew list --verbose\n———————————————————\n' > $listBrew && brew list --verbose >> $listBrew && listBrew='' && printf '\n\n\xe2'$listBrew'\x9c\x85 done\x21\n\n'
```
###### Cask
```bash
listBrewCask=$DOTFILES/!=Mackup/brew\ cask\ list && touch $listBrewCask && printf 'brew cask list\n—————————————\n' > $listBrewCask && brew cask list >> $listBrewCask && listBrewCask='' && printf '\n\n\xe2'$listBrewCask'\x9c\x85 done\x21\n\n'
```
##### $MANPATH
```bash
saveMANPATH=-1 && mkdir -p $DOTFILES/\!=Mackup && filename=$DOTFILES/\!=Mackup/MANPATH && touch $filename && printf '# $MANPATH’s contents\n# ' > $filename && date '+%Y-%m-%d' >> $filename && printf '# ———————————————————————\n' >> $filename && <<<${(F)manpath} >> $filename && cd $DOTFILES && mackup backup && git fetch && git submodule update --init --recursive && git status && git diff $filename && filename='' && saveMANPATH=$filename && printf '\n\n\xe2'$filename'\x9c'$saveMANPATH'\x85 done!\n\n'
```
##### pip packages
```bash
pip list && mkdir -p ~/Dropbox/Mackup/\!=Mackup && printf 'pip packages installed ' > ~/Dropbox/Mackup/\!=Mackup/pip && date '+%Y-%m-%d' >> ~/Dropbox/Mackup/\!=Mackup/pip && printf '—————————————————————————————————\n' >> ~/Dropbox/Mackup/\!=Mackup/pip && pip list >> ~/Dropbox/Mackup/\!=Mackup/pip && cd ~/Dropbox/Mackup && mackup backup && git fetch && git submodule update --init --recursive && git status && git diff \!=Mackup/pip && printf '\n\n\xe2\x9c\x85 done\x21\n\n'
```
## search
### `grep`
search for the word “example” inside the current directory which is “.”<br/>
`grep -inr 'example' .`<br/>
`-i` means case-<u>i</u>nsensitive<br/>
`-n` means show line <u>n</u>umbers<br/>
`-r` means <u>r</u>ecursively or in a scope bigger than a file which is the dot

### locate all
for example, locate all JPEG files<br/>
`locate -i *.jpg #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#search-via-locate); see also [§ grep](#grep)

## `$PATH`

### entries
#### macOS
`<<<${(F)path}` # [via](https://codegolf.stackexchange.com/a/96471)

#### Linux
```bash
PathSave=-1 && mkdir -p ~/Code/Dotfiles && cd ~/Code/Dotfiles && printf 'PATH\n' > PATH && date '+%Y-%m-%d' >> PATH && printf 'automagically generated' >> PATH && printf '\n———————————————————————\n' >> PATH && <<<${(F)path} >> PATH && git fetch && git submodule update --init --recursive && git status && git diff PATH && printf '\n\n\xe2\x9c\x85 done\x21\n\n' && PathSave=0
```
## text editing
### export output
`printf 'First Name\n' > ExampleFileWithGivenName.txt` # create a text file with “First Name” and a new line<br/>
`printf 'Other First Name\n' `**>**` ExampleFileWithGivenName.txt` # the “`>`” *overwrites* the existing file<br/>
`printf "Last Name\n" `**>>**` ExampleFileWithGivenName.txt` # the “`>>`” *appends* to the existing document

## make invisible
`chflags hidden example.txt`

## create an alias
`ln -s file shortcut #` [via](https://www.reddit.com/r/programming/comments/1qt0z/ln_s_d1_d2_am_i_the_only_person_who_gets_this_the/c1qtge/)<br/>
(just like `cp existing new`)

## launch services
### reset
remove bogus entries from Finder’s “Open With” menu ([via](https://github.com/mathiasbynens/dotfiles/blob/e42090bf49f860283951041709163653c8a2c522/.aliases#L69-L70))<br/>
`/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -seed -r -domain local -domain system -domain user && killall Finder`

### repair website disk permissions
`find /path/to/your/wordpress -type d -exec chmod 755 {} \; && \`<br/>
`find /path/to/your/wordpress -type f -exec chmod 644 {} \; #` [via](https://wordpress.org/support/article/hardening-wordpress/#changing-file-permissions)

#### date modified modify
`touch -t 2003040500 file.txt` \# date modified → 2020-03-04 5:00am

### flags for C, C++
`-Wall -Wextra -pedantic`<br/>
`#ifdef __APPLE__`<br/>
    `-Weverything <!--` do not use ([via](https://web.archive.org/web/20190926015534id_/quuxplusone.github.io/blog/2018/12/06/dont-use-weverything/#for-example-if-you-want-to-see-a)) `-->`<br/>
`#endif`<br/>
`-Woverriding-method-mismatch -Weffc++ -Wcall-to-pure-virtual-from-ctor-dtor -Wmemset-transposed-args -Wreturn-std-move -Wsizeof-pointer-div -Wdefaulted-function-deleted` # [via](https://archive.is/2019.06.25-171347/https:/github.com/jonreid/XcodeWarnings/issues/8#19%25)<br/>
`-lstdc++ #` [via](https://web.archive.org/web/20200517174238id_/unspecified.wordpress.com/2009/03/15/linking-c-code-with-gcc/amp/#post-consent-ui) but this might – or might not – be helpful on macOS using gcc or g++

#### C++ features before wide support
for example, C++17’s `<filesystem>`<br/>
`-lstdc++fs`

## Gatekeeper
do not disable it, because that would allow you to install any software, even if unsigned, even if malicious:<br/>
`sudo spctl --master-disable #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/bd25a136655e63fcb7f3462a8dc7105f30093e54/README.md#manage-gatekeeper)

## Git
### `init` via GitHub
`git push --set-upstream git@github.com:LucasLarson/$(git rev-parse --show-toplevel | xargs basename).git $(git rev-parse --abbrev-ref HEAD)`

### `add`
[via](https://stackoverflow.com/a/15011313)
<table>
<tr class="odd">
<td><p>Modified files only</p></td>
<td><code>git add -u</code></td>
</tr>
<tr class="even">
<td><p>Everything, without deleted Files</p></td>
<td><code>git add .</code></td>
</tr>
<tr class="odd">
<td><p><strong>Everything</strong></p></td>
<td><code>git add -A</code></td>
</tr>
</table>

### `diff`
more detailed `git diff` and how I once found an LF‑to‑CRLF‑only difference<br/>
`git diff --raw`

### `commit`
#### with subject *and* body
`git commit -m 'subject' -m 'body' #` [via](https://stackoverflow.com/a/40506149)
#### in the past
to backdate a commit:<br/>
`GIT_TIME='`**2000-01-02T15:04:05 -0500**`' GIT_AUTHOR_DATE=$GIT_TIME GIT_COMMITTER_DATE=$GIT_TIME git commit -m 'add modifications made at 3:04:05pm EST on January 2, 2000' #` [via](https://stackoverflow.com/questions/3895453/how-do-i-make-a-git-commit-in-the-past#comment97787061_3896112)

### `editor`
Vim<br/>
`git config --global core.editor /usr/local/bin/vim`<br/>
Atom [via](https://stackoverflow.com/a/31389989 )<br/>
`git config --global core.editor "atom --wait"`

### rename files
`brew install --upgrade rename && #` [via](https://stackoverflow.com/a/31694356) `\`<br/>
`rename -nvs searchword replaceword *`

### split enormous files into something manageable
if your example.csv has too many rows ([via](https://archive.today/2019.11.14-162132/https:/domains-index.com/best-way-view-edit-large-csv-files/#24%25))<br/>
`split -l 2000 example.csv; for i in *; do mv "$i" "$i.csv"; done`

## SSH
`ssh username@example.com`

#### `ls` on Windows
`dir` # [via](https://stackoverflow.com/a/58740114)

## wget
`wgetserver=`'**example.com**' `&& \`<br/>
`wget --mirror --continue --verbose --append-output=$wgetserver.log --execute robots=off --restrict-file-names=nocontrol --timestamping --convert-links --show-progress http://$wgetserver`

## WiFi
### password
#### Windows
`netsh wlan show profile WiFi-name key=clear #` [via](https://reddit.com/r/LifeProTips/comments/d5vknk/lpt_if_you_ever_forget_your_wifi_password_or_you/)
#### macOS
`security find-generic-password -wa ExampleNetwork #` [via](https://www.labnol.org/software/find-wi-fi-network-password/28949/)

## Xcode
### signing
`PRODUCT_BUNDLE_IDENTIFIER = net.LucasLarson.$(PRODUCT_NAME:rfc1034identifier);`<br/>
`PRODUCT_NAME = $(PROJECT_NAME);`<br/>
`DEVELOPMENT_TEAM = Z25963JBNP;`<br/>
`DevelopmentTeam = Z25963JBNP;`

## housekeeping
### Homebrew
`brew doctor --debug --verbose && \`<br/>
`brew cask doctor && \`<br/>
`brew cleanup --debug --verbose && #` [via](https://stackoverflow.com/a/41030599) `\`<br/>
`brew cask audit --strict --token-conflicts`

### npm
`npm doctor #` creates empty “node_modules” folders

### RubyGems
`gem cleanup`

### Flutter
`cd ~/Code/Flutter && git pull && flutter upgrade && flutter precache && flutter doctor --verbose`

### Xcode and JetBrains
`trashXcodeJetBrains=-1 && sleep 0.25 && mkdir -p ~/Library/Developer/Xcode/DerivedData && mv ~/Library/Developer/Xcode/DerivedData ~/.Trash/Xcode-$RANDOM && mkdir -p ~/Library/Caches/JetBrains && mv ~/Library/Caches/JetBrains ~/.Trash/JetBrains-$RANDOM && unset trashXcodeJetBrains && printf '\n\n\xf0'$trashXcodeJetBrains'\x9f'$trashXcodeJetBrains'\x9a'$trashXcodeJetBrains'\xae data successfully trashed\n\n'`

## delete
### with confirmation first
`rm -i /ExampleDirectoryFullOfImportantDocuments`<br/>
`rm -i /ExampleTrashDocument.txt # -i` stands for <u>i</u>nteractive

### without confirmation
`rm -rf /ExampleDirectoryFullOfImportantDocuments` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#securely-remove-path-force)<br/>
`rm     /ExampleTrashDocument.txt`

### empty directories
make a list of empty folders inside and beneath current directory **`.`** ([via](https://unix.stackexchange.com/a/46326))<br/>
`find . -type d -empty -print`<br/>
if satisfied with the results being lost and gone forever, execute:<br/>
<span title="You were warned: don’t do this!">`find . -type d -empty -delete`</span>

### compare two folders
`diff -qr /path/to/folder1 /path/to/folder2` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#compare-two-folders)

### purge memory cache
`sudo purge` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#purge-memory-cache)
