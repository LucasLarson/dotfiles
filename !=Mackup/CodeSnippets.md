# Code snippets
<!-- TOC -->

- [Code snippets](#code-snippets)
  - [copy, paste, return](#copy-paste-return)
    - [detail](#detail)
  - [Mackup](#mackup)
    - [add](#add)
      - [manual](#manual)
        - [lists](#lists)
          - [applications](#applications)
  - [search](#search)
    - [`grep`](#grep)
    - [locate all](#locate-all)
  - [`$PATH`](#path)
    - [entries](#entries)
    - [sandbox](#sandbox)
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
  - [Git](#git)
    - [`init` via GitHub](#init-via-github)
    - [`add`](#add)
    - [`diff`](#diff)
    - [`commit` with subject ***and*** body](#commit-with-subject-and-body)
    - [`editor`](#editor)
    - [rename files](#rename-files)
    - [split enormous files into something manageable](#split-enormous-files-into-something-manageable)
  - [SSH](#ssh)
    - [`ls` on Windows](#ls-on-windows)
  - [wget](#wget)
  - [WiFi](#wifi)
    - [password](#password)
      - [Windows](#windows)
      - [macOS](#macos)
- [delete](#delete)
  - [with confirmation first](#with-confirmation-first)
  - [without confirmation](#without-confirmation)
    - [compare two folders](#compare-two-folders)
      - [purge memory cache](#purge-memory-cache)

<!-- /TOC -->
<!-- @TODO
   brew doctor
&& brew cask doctor
&& brew cleanup
&& npm doctor
&& gem cleanup
&& flutter doctor -v
-->

## copy, paste, return
```bash
brew update && brew upgrade && brew cask upgrade && xcrun simctl delete unavailable && upgrade_oh_my_zsh && rustup update && npm install npm -g && npm update -g && apm upgrade && gem update --system && gem update && rbenv rehash && python -m pip install --upgrade pip && pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install --upgrade && pip install --upgrade $(pip freeze | cut -d '=' -f 1) && pyenv rehash && source ~/.zshrc && printf '\n\n✅ done!\n\n' && exec zsh
```
### detail
`xcode-select --install && \`<br/>
`xcrun simctl delete unavailable && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/d7406c3bb347af9fb1734885ed571117a5dbf90a/README.md#remove-all-unavailable-simulators) `\`<br/>
`brew update --debug --verbose && #` [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/launchagents.md#periodic-homebrew-update-and-upgrade)`,` [via](https://stackoverflow.com/a/47664603) `\`<br/>
`brew upgrade && \`<br/>
`brew cask upgrade && #` [via](https://github.com/hisaac/hisaac.net/blob/8c63d51119fe2a0f05fa6c1c2a404d12256b0594/source/_posts/2018/2018-02-12-update-all-the-things.md#readme) `\`<br/>
`brew doctor --debug --verbose && \`<br/>
`brew cleanup --debug --verbose && #` [via](https://stackoverflow.com/a/41030599) `\`<br/>
`brew install mackup --devel && #` 0.8.28 [2020-02-26](https://github.com/lra/mackup/blob/master/CHANGELOG.md#mackup-changelog) `\`<br/>
`mackup backup && # || mackup backup --force \`<br/>
`upgrade_oh_my_zsh && #` [via](https://github.com/robbyrussell/oh-my-zsh/blob/17f4cfca99398cb5511557b8515a17bf1bf2948a/README.md#manual-updates) `\`<br/>
`git clone --recursive --recurse-submodules --depth=1 --branch master #` [via](https://github.com/mapsme/omim/blob/f93cc4cc270baa886ad9bfccca2fc5e815f7245e/README.md#submodules), [via](https://github.com/hisaac/Tiime/blob/ff1a39d6765d8ae5c9724ca84d5c680dff4c602e/README.md#bootstrapping-instructions), [via](https://stackoverflow.com/a/50028481) `\`<br/>
`git submodule update --init --recursive && #` [via](https://stackoverflow.com/a/10168693) `\`<br/>
`npm install npm -g && #` [via](https://github.com/mathiasbynens/dotfiles/blob/e42090bf49f860283951041709163653c8a2c522/.aliases#L51-L52) `\`<br/>
`npm update -g && #` 6.14.5 [2020-05-04](https://www.npmjs.com/package/npm?activeTab=versions#versions) `\`<br/>
`apm upgrade && #` via npm analogy `\`<br/>
`gem update --system && #`  3.1.2 [2019-12-20](https://blog.rubygems.org) `\`<br/>
`gem update && \`<br/>
`gem install bundler --pre && #`  2.1.4 [2020-01-05](https://rubygems.org/gems/bundler/versions) `\`<br/>
`gem install cocoapods --pre && #`  1.9.1 [2020-03-09](https://rubygems.org/gems/cocoapods/versions) `\`<br/>
`gem cleanup && \`<br/>
`bundle update && #` [via](https://github.com/ffi/ffi/issues/651#issuecomment-513835103) `\`<br/>
`bundle install --verbose && \`<br/>
`bundle exec pod install --verbose && \`<br/>
`pod repo update && pod repo update && \`<br/>
`pod install && \`<br/>
`pod update && #` [via](https://web.archive.org/web/20190719112335id_/https:/guides.cocoapods.org/using/pod-install-vs-update.html#pod-update) `\`<br/>
`rbenv rehash && pyenv rehash && \`<br/>
`python -m pip install --upgrade pip` && # 20.1.1 [2020-05-19](https://pip.pypa.io/en/stable/news/#id1) [via](https://opensource.com/article/19/5/python-3-default-mac#comment-180271), [via](https://github.com/pypa/pip/blob/52309f98d10d8feec6d319d714b0d2e5612eaa47/src/pip/_internal/self_outdated_check.py#L233-L236) `\`<br/>
`pip list --outdated --format=freeze \`<br/>
    `| grep -v '^\-e' \`<br/>
    `| cut -d = -f 1 \`<br/>
    `| xargs -n1 pip install --upgrade && #` [via](https://stackoverflow.com/revisions/3452888/14) `\`<br/>
`pip install --upgrade $(pip freeze | cut -d '=' -f 1) && #` [via](https://web.archive.org/web/20200508173219id_/coderwall.com/p/quwaxa/update-all-installed-python-packages-with-pip#comment_29830) `\`<br/>
`pipenv shell &&` # [via](https://github.com/pypa/pipenv/blob/bfbe1304f63372a0eb7c1531590b51195db453ea/pipenv/core.py?instructions_while_running_pipenv_install#L1282) `\`<br/>
`pipenv install --dev && #` [via](https://stackoverflow.com/a/49867443) `\`<br/>
`rustup update && #` 1.43.1 [2020-05-07](https://github.com/rust-lang/rust/releases) `\`<br/>
`source ~/.zsh && \`<br/>
`brew install carthage --devel && #` 0.34.0 [2019-10-21](https://github.com/Carthage/Carthage/releases) `\`<br/>
`carthage update --no-use-binaries && #` [via](https://stackoverflow.com/a/41526660) `\`<br/>
`brew install swiftgen --devel && #`  6.1.0 [2019-01-29](https://github.com/SwiftGen/SwiftGen/releases) `\`<br/>
`swiftgen && \`<br/>
`brew install swiftlint --devel && #` 0.39.1 [2020-02-11](https://github.com/realm/SwiftLint/releases) `\`<br/>
`swiftlint autocorrect && \`<br/>
`git submodule update --init --recursive && \`<br/>
`# git add . && git add -u || git add -A && #` [via](https://stackoverflow.com/a/15011313) `\`<br/>
`git gc && \`<br/>
`mv ~/Library/Developer/Xcode/DerivedData ~/.Trash/Xcode-$RANDOM && \`<br/>
`# npm doctor #` creates empty node_modules folders && `\`<br/>
`# gradle build --refresh-dependencies --warning-mode all && #` [via](https://stackoverflow.com/a/35374051) `\`<br/>
`printf '\n\n✅ done!\n\n' && #` [via](https://stackoverflow.com/a/30762087) `\`<br/>
`exec zsh #` note successful finish before restarting the shell

## Mackup
### add
#### manual
to add dotfiles, for example, of the variety [Mackup](https://github.com/lra/mackup) might’ve but hasn’t
`add='`**~/Desktop/example.txt**`' && cp ~/$add ~/Dropbox/Mackup/$add && mv ~/$add ~/.Trash && ln -s ~/Dropbox/Mackup/$add ~/$add`

##### lists
###### applications
track changes to which applications are installed without syncing them<br/>
```bash
mkdir -p ~/Dropbox/Mackup/\!=Mackup && mkdir -p /Applications && cd /Applications && pwd > ~/Dropbox/Mackup/\!=Mackup/:Applications && date '+%Y-%m-%d' >> ~/Dropbox/Mackup/\!=Mackup/:Applications && ls -F1 >> ~/Dropbox/Mackup/\!=Mackup/:Applications && cd ~/Dropbox/Mackup && mackup backup && git fetch && git submodule update --init --recursive && git status && git diff \!=Mackup/:Applications && printf '\n\n✅ done!\n\n'
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
`<<<${(F)path}` # [via](https://codegolf.stackexchange.com/a/96471)

### sandbox
If you need to have ruby first in your PATH run:<br/>
`echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc`

For compilers to find ruby you may need to set:<br/>
`export LDFLAGS="-L/usr/local/opt/ruby/lib"`<br/>
`export CPPFLAGS="-I/usr/local/opt/ruby/include"`

For pkg-config to find ruby you may need to set:<br/>
`export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"`

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
`sudo $(locate lsregister) -kill -seed -r`<br/>

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

### `commit` with subject ***and*** body
`git commit -m 'subject' -m 'body' #` [via](https://stackoverflow.com/a/40506149)<br/>

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
`git clone ssh://example.com/home/username/example.com/public/.git`<br/>
`ssh username@example.com`

#### `ls` on Windows
`dir` # [via](https://stackoverflow.com/a/58740114)

## wget
`wgetserver=`'**example.com**' `&& \`<br/>
`wget --mirror --continue --verbose --append-output=$wgetserver.log --execute robots=off --restrict-file-names=nocontrol http://$wgetserver`

`wgetserver=`'**example.com**' `&& \`<br/>
`wget -m -c -v -a $wgetserver.log -e robots=off --restrict-file-names=nocontrol http://$wgetserver`

## WiFi
### password
#### Windows
`netsh wlan show profile WiFi-name key=clear #` [via](https://reddit.com/r/LifeProTips/comments/d5vknk/lpt_if_you_ever_forget_your_wifi_password_or_you/)
#### macOS
`security find-generic-password -wa ExampleNetwork #` [via](https://www.labnol.org/software/find-wi-fi-network-password/28949/)

# delete
## with confirmation first
`rm -i /ExampleDirectoryFullOfImportantDocuments`<br/>
`rm -i /ExampleTrashDocument.txt # -i` stands for <u>i</u>nteractive

## without confirmation
`rm -rf /ExampleDirectoryFullOfImportantDocuments` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#securely-remove-path-force)<br/>
`rm     /ExampleTrashDocument.txt`

### compare two folders
`diff -qr /path/to/folder1 /path/to/folder2` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#compare-two-folders)

##### purge memory cache
`sudo purge` # [via](https://github.com/herrbischoff/awesome-macos-command-line/blob/cf9e47c26780aa23206ecde6474426071fb54f71/README.md#purge-memory-cache)
