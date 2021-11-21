#!/usr/bin/env zsh

# Powerlevel10k instant prompt
# https://github.com/romkatv/powerlevel10k/tree/d394a4e#how-do-i-enable-instant-prompt
[ -r "${XDG_CACHE_HOME:=${HOME}/.cache}/p10k-instant-prompt-$(command id -n -u).zsh" ] &&
  . "${XDG_CACHE_HOME:=${HOME}/.cache}/p10k-instant-prompt-$(command id -n -u).zsh"

# PATH
# https://opengroup.org/onlinepubs/9699919799/utilities/command.html
# prepend without extra colon
# https://unix.stackexchange.com/a/415028
PATH="$(command -p getconf PATH)${PATH:+:${PATH}}"
# https://github.com/archlinux/svntogit-packages/commit/a10f20b/filesystem/trunk/profile
[ -d '/usr/local/sbin' ] &&
  PATH="/usr/local/sbin${PATH:+:${PATH}}"

# /usr/local/bin first
# https://stackoverflow.com/a/34984922
[ -d '/usr/local/bin' ] &&
  PATH="/usr/local/bin${PATH:+:${PATH}}"

# set PATH so it includes applicable private `bin`s
[ -d "${HOME}/bin" ] &&
  PATH="${HOME}/bin${PATH:+:${PATH}}"
[ -d "${HOME}/.local/bin" ] &&
  PATH="${HOME}/.local/bin${PATH:+:${PATH}}"

# Plugin manager installation
[ -d "${HOME}/.oh-my-zsh" ] &&
  export ZSH="${HOME}/.oh-my-zsh"

# Use a custom folder other than $ZSH/custom
# ZSH_CUSTOM=/path/to/new-custom-folder
# https://reddit.com/comments/g1a2qd/_/fneil10
export ZSH_CUSTOM="${DOTFILES}/custom"
export ZSHCUSTOM="${ZSH_CUSTOM}"

# Theme
# Set name of the theme to load. If set to `random`, it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# powerlevel10k
# https://github.com/romkatv/powerlevel10k/blob/48c6ff4/README.md#oh-my-zsh
if [ -r "${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme" ] &&
  [ "$((COLUMNS * LINES))" -gt "$((80 * 24))" ]; then
  ZSH_THEME='powerlevel10k/powerlevel10k'
else
  ZSH_THEME='robbyrussell'
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
export ZSH_THEME

# Uncomment the following line to use case-sensitive completion.
# export CASE_SENSITIVE='true'

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# export HYPHEN_INSENSITIVE='true'

# Uncomment the following line to disable bi-weekly auto-update checks.
export DISABLE_AUTO_UPDATE='true'

# Uncomment the following line to automatically update without prompting.
export DISABLE_UPDATE_PROMPT='true'

# Uncomment the following line to change how often, in days, to autoupdate.
export UPDATE_ZSH_DAYS='1'

# Magic functions prevent easy pasting of URLs containing `#`, `?`
export DISABLE_MAGIC_FUNCTIONS='true'

# Uncomment the following line to disable colors in ls.
# export DISABLE_LS_COLORS='true'

# Uncomment the following line to disable auto-setting terminal title.
# export DISABLE_AUTO_TITLE='true'

# Uncomment the following line to enable command auto-correction.
# This is an unhelpful, badly documented setting and should not be enabled.
export ENABLE_CORRECTION='false'

# Uncomment the following line to display red dots whilst awaiting completion.
export COMPLETION_WAITING_DOTS='true'

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# export DISABLE_UNTRACKED_FILES_DIRTY='true'

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
export HIST_STAMPS='yyyy-mm-dd'

# set maximum number of lines in history file
# https://unix.stackexchange.com/a/273929
# https://stackoverflow.com/a/13111995
# https://unix.stackexchange.com/a/111777
SAVEHIST="$(printf '2 ^ 32 - 1\n' | command bc)" # 4,294,967,295 in history file
HISTSIZE="$((SAVEHIST / 2))"                     # 2,147,478,647 in session
export SAVEHIST HISTSIZE

# ~/.zcompdump override
# https://github.com/ohmyzsh/ohmyzsh/commit/d2fe03d
export ZSH_COMPDUMP="${HOME}/.zcompdump"

# Plugins
# plugins at the beginning of the array are
# overridden by plugins at its end
plugins=(
  "${plugins[@]}"
  git
  gunstage
  samefile
  git-default-branch
  git-open
  history-substring-search
  zsh-diff-so-fancy
  zchee-zsh-completions
)
[ "$(command uname)" = 'Darwin' ] &&
  plugins=(
    "${plugins[@]}"
    fast-syntax-highlighting
  )

# trapd00r/LS_COLORS: .dircolors to override Oh My Zsh’s `ls -G` for coreutils
# https://github.com/ohmyzsh/ohmyzsh/blob/d0d01c0/lib/theme-and-appearance.zsh
# https://github.com/trapd00r/LS_COLORS/tree/6a4d29b#installation
# https://github.com/paulirish/dotfiles/blob/ccccd07/.dircolors
[ -r "${HOME}/.local/share/lscolors.sh" ] &&
  . "${HOME}/.local/share/lscolors.sh"

. "${ZSH}/oh-my-zsh.sh"

# User configuration

# MANPATH
# Linux
[ -d '/usr/local/man' ] &&
  # skip adding initial and terminal colons `:`
  # https://unix.stackexchange.com/a/162893
  MANPATH="/usr/local/man${MANPATH:+:${MANPATH}}"
# macOS
[ -d '/usr/share/man' ] &&
  MANPATH="/usr/share/man${MANPATH:+:${MANPATH}}"
# if `man -w` does not fail, then add it to `$MANPATH`
command man -w >/dev/null 2>&1 &&
  # skip adding initial and terminal colons `:`
  # https://unix.stackexchange.com/a/162893
  MANPATH="${MANPATH:+${MANPATH}:}$(command man -w)"

# $EDITOR: access favorite with `edit`
# Set preferred editor if it is available
# https://stackoverflow.com/a/14755066
# https://github.com/wililupy/snapd/commit/0573e7b
if command -v nvim >/dev/null 2>&1; then
  EDITOR="$(command -v nvim)"
elif command -v vim >/dev/null 2>&1; then
  EDITOR="$(command -v vim)"
else
  EDITOR="$(command -v vi)"
fi
export EDITOR
# https://github.com/koalaman/shellcheck/wiki/SC2139/db553bf#this-expands-when-defined-not-when-used-consider-escaping
alias editor='${EDITOR}'
alias edit='editor'
# https://unix.stackexchange.com/q/4859#comment5812_4861
export VISUAL="${EDITOR}"

# ignore case in `man` page searches
# https://unix.stackexchange.com/a/101299
# https://github.com/awdeorio/dotfiles/commit/65ff822
PAGER='command less --IGNORE-CASE'
export PAGER
export MANPAGER="${PAGER}"
alias less='${PAGER}'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# iTerm
[ -r "${HOME}/.iterm2_shell_integration.zsh" ] &&
  . "${HOME}/.iterm2_shell_integration.zsh"

# GPG signing with macOS-compatible Linux
# https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key#telling-git-about-your-gpg-key
# https://reddit.com/comments/dk53ow/_/f50146x
# https://github.com/romkatv/powerlevel10k/commit/faddef4
export GPG_TTY="${TTY-}"

# Homebrew
# https://github.com/Homebrew/brew/blob/a5b6c5f/Library/Homebrew/diagnostic.rb#L432-L435
if command -v brew >/dev/null 2>&1; then

  # https://github.com/driesvints/dotfiles/blob/388baf1/path.zsh#L17
  BREW_PREFIX="$(command brew --prefix)"
  [ -d "${BREW_PREFIX}/sbin" ] &&
    PATH="${BREW_PREFIX}/sbin${PATH:+:${PATH}}"

  # GNU bc calculator
  [ -d "${BREW_PREFIX}/opt/bc/bin" ] &&
    PATH="${BREW_PREFIX}/opt/bc/bin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/bc/share/man" ] &&
    # Homebrew `MANPATH`
    # https://github.com/ferrarimarco/dotfiles/blob/eb176e4/.path#L14-L20
    MANPATH="${BREW_PREFIX}/opt/bc/share/man${MANPATH:+:${MANPATH}}"

  # curl
  [ -d "${BREW_PREFIX}/opt/curl/bin" ] &&
    PATH="${BREW_PREFIX}/opt/curl/bin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/curl/share/man" ] &&
    MANPATH="${BREW_PREFIX}/opt/curl/share/man${MANPATH:+:${MANPATH}}"

  # GNU coreutils
  # for `date`, `cat`, `ln`
  # https://apple.stackexchange.com/a/135749
  [ -d "${BREW_PREFIX}/opt/coreutils/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/coreutils/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/coreutils/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/coreutils/libexec/gnuman${MANPATH:+:${MANPATH}}"

  # GNU findutils
  # for `find`, `xargs`, `locate`
  [ -d "${BREW_PREFIX}/opt/findutils/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/findutils/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/findutils/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/findutils/libexec/gnuman${MANPATH:+:${MANPATH}}"

  # grep
  # use latest via Homebrew but without the `g` prefix
  # https://github.com/Homebrew/homebrew-core/blob/ba7a70f/Formula/grep.rb#L43-L46
  [ -d "${BREW_PREFIX}/opt/grep/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/grep/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/grep/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/grep/libexec/gnuman${MANPATH:+:${MANPATH}}"

  # libarchive
  [ -d "${BREW_PREFIX}/opt/libarchive/bin" ] &&
    PATH="${BREW_PREFIX}/opt/libarchive/bin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/libarchive/share/man" ] &&
    MANPATH="${BREW_PREFIX}/opt/libarchive/share/man${MANPATH:+:${MANPATH}}"

  # make
  # use latest via Homebrew but without the `g` prefix
  # https://github.com/Homebrew/homebrew-core/blob/9591758/Formula/make.rb#L37-L41
  [ -d "${BREW_PREFIX}/opt/make/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/make/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/make/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/make/libexec/gnuman${MANPATH:+:${MANPATH}}"

  # openssl
  [ -d "${BREW_PREFIX}/opt/openssl/bin" ] &&
    PATH="${BREW_PREFIX}/opt/openssl/bin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/openssl/share/man" ] &&
    MANPATH="${BREW_PREFIX}/opt/openssl/share/man${MANPATH:+:${MANPATH}}"
  # `$LDFLAGS`, `$CPPFLAGS` are space-delimited
  # https://thelinuxcluster.com/2018/11/13/using-multiple-ldflags-and-cppflags
  # skip adding initial and terminal spaces
  # https://unix.stackexchange.com/a/162893
  export LDFLAGS="${LDFLAGS:+${LDFLAGS} }-L${BREW_PREFIX}/opt/openssl/lib"
  export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS} }-I${BREW_PREFIX}/opt/openssl/include"

  # PKG_CONFIG_PATH is colon-delimited
  # https://superuser.com/a/1277306
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+${PKG_CONFIG_PATH}:}${BREW_PREFIX}/opt/openssl/lib/pkgconfig"

  # sed
  # https://github.com/Homebrew/homebrew-core/blob/8ec6f0e/Formula/gnu-sed.rb#L35-L39
  [ -d "${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/gnu-sed/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/gnu-sed/libexec/gnuman${MANPATH:+:${MANPATH}}"

  # texinfo for `info`
  # “more detailed than . . . manpage (as is true for most GNU utilities)”
  # https://stackoverflow.com/a/1489405
  [ -d "${BREW_PREFIX}/opt/texinfo/bin" ] &&
    PATH="${BREW_PREFIX}/opt/texinfo/bin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/texinfo/share/man" ] &&
    MANPATH="${BREW_PREFIX}/opt/texinfo/share/man${MANPATH:+:${MANPATH}}"

  # which
  [ -d "${BREW_PREFIX}/opt/gnu-which/libexec/gnubin" ] &&
    PATH="${BREW_PREFIX}/opt/gnu-which/libexec/gnubin${PATH:+:${PATH}}"
  [ -d "${BREW_PREFIX}/opt/gnu-which/libexec/gnuman" ] &&
    MANPATH="${BREW_PREFIX}/opt/gnu-which/libexec/gnuman${MANPATH:+:${MANPATH}}"
fi

# Rust Cargo
# if its `bin` is a directory, then add it to `PATH`
[ -d "${HOME}/.cargo/bin" ] &&
  PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"

# Bashhub.com
[ -r "${HOME}/.bashhub/bashhub.zsh" ] &&
  . "${HOME}/.bashhub/bashhub.zsh"

# npm without sudo
# https://github.com/sindresorhus/guides/blob/285270f/npm-global-without-sudo.md#3-ensure-npm-will-find-installed-binaries-and-man-pages
NPM_PACKAGES="${HOME}/.npm-packages"
[ -d "${NPM_PACKAGES}/bin" ] &&
  PATH="${PATH:+${PATH}:}${NPM_PACKAGES}/bin"
[ -d "${NPM_PACKAGES}/share/man" ] &&
  MANPATH="${MANPATH:+${MANPATH}:}${NPM_PACKAGES}/share/man"

# Template repositories
[ -d "${TEMPLATE:=${DOTFILES:=${HOME}/Dropbox/dotfiles}/../Template}" ] &&
  export TEMPLATE
[ -d "${DEFAULT:=${DOTFILES:=${HOME}/Dropbox/dotfiles}/../Default}" ] &&
  export DEFAULT

# completion dots
# https://git.io/completion-dots-in-.zshrc
expand-or-complete-with-dots() {
  printf '\033[0;31m...\033[0m'
  zle expand-or-complete
  zle redisplay
}

# include hidden files in tab completion
# https://unix.stackexchange.com/a/366137
setopt GLOB_DOTS
# but hide `./` and `../`
# https://unix.stackexchange.com/q/308315#comment893697_308322
zstyle ':completion:*' special-dirs false
# https://github.com/TimButters/dotfiles/blob/3e03c81/zshrc#L46-L50
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %F"{green}"%d%f

# zsh-completions
# https://github.com/Homebrew/homebrew-core/blob/7cf42e0/Formula/zsh-completions.rb#L18-L23
# https://github.com/zsh-users/zsh-completions/tree/f68950a#oh-my-zsh
[ -d "${ZSH_CUSTOM}/plugins/zsh-completions/src" ] &&
  # skip adding initial and terminal colons `:`
  # https://unix.stackexchange.com/a/162893
  FPATH="${FPATH:+${FPATH}:}${ZSH_CUSTOM}/plugins/zsh-completions/src"

autoload -U compinit &&
  compinit

# share all commands from everywhere
# https://github.com/mcornella/dotfiles/blob/047eaa1/zshrc#L104-L105
setopt SHARE_HISTORY

# permit inline comments after hash signs `#`
# https://stackoverflow.com/a/11873793
setopt INTERACTIVE_COMMENTS

# pyenv
[ -d "${HOME}/.pyenv/shims" ] &&
  PATH="${HOME}/.pyenv/shims${PATH:+:${PATH}}"
# https://git.io/init_-_--no-rehash
# https://github.com/caarlos0/carlosbecker.com/commit/c5f04d6
pyenv() {
  eval "$(command pyenv init - --no-rehash "${SHELL##*[-./]}")"
  pyenv "$@"
}

# C, C++ headers
# https://apple.stackexchange.com/a/372600
if command -v xcrun >/dev/null 2>&1 &&
  [ -n "$(command xcrun --show-sdk-path)" ]; then
  # `CPATH` is delimited like `PATH` as are
  # `C_INCLUDE_PATH`, `OBJC_INCLUDE_PATH`,
  # `CPLUS_INCLUDE_PATH`, and `OBJCPLUS_INCLUDE_PATH`
  # https://github.com/llvm/llvm-project/commit/16af476
  CPATH="$(command xcrun --show-sdk-path)/usr/include${CPATH:+:${CPATH}}"
  export CPATH
fi

# cpplint tests
# `$LIBRARY_PATH` || ld: library not found for -lSystem
# https://stackoverflow.com/a/65428700
if [ -d '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib' ]; then
  # skip adding initial and terminal colons `:`
  # https://unix.stackexchange.com/a/162893
  LIBRARY_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
  export LIBRARY_PATH
fi

# Flutter
# https://github.com/flutter/website/blob/e5f725c/src/docs/get-started/install/_path-mac.md#user-content-update-your-path
# if `~/Code/Flutter/bin/flutter`’s an executable
# and `flutter`’s not in the PATH, then add it
if [ -x "${HOME}/Code/Flutter/bin/flutter" ]; then
  if ! command -v flutter >/dev/null 2>&1; then
    PATH="${PATH:+${PATH}:}${HOME}/Code/Flutter/bin"
  fi
fi

# Android SDK
# if it’s a directory, then assign it the name `ANDROID_SDK_ROOT`
[ -d "${HOME}/Library/Android/sdk" ] &&
  export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"

# pip
# location of Python packages on Linux
[ -d "${HOME}/.local/bin" ] &&
  PATH="${HOME}/.local/bin${PATH:+:${PATH}}"

# rbenv
# https://hackernoon.com/the-only-sane-way-to-setup-fastlane-on-a-mac-4a14cb8549c8#6a04
# https://git.io/init_-_--no-rehash
# https://github.com/caarlos0/carlosbecker.com/commit/c5f04d6
[ -d "${HOME}/.rbenv/shims" ] &&
  PATH="${HOME}/.rbenv/shims${PATH:+:${PATH}}"
rbenv() {
  eval "$(command rbenv init - --no-rehash "${SHELL##*[-./]}")"
  rbenv "$@"
}

# Radicle
# https://github.com/radicle-dev/radicle-docs/blob/a0f08f4/docs/getting-started/doc1-1.md#configuring-your-system
[ -d "${HOME}/.radicle/bin" ] &&
  PATH="${HOME}/.radicle/bin${PATH:+:${PATH}}"

# automatically remove PATH duplicates
# https://github.com/mcornella/dotfiles/blob/e62b0d4/zshenv#L63-L67
# https://github.com/zsh-users/zsh/blob/a9061cc/StartupFiles/zshrc#L56-L57
# https://github.com/zsh-users/zsh/commit/db3f2d2
[ -n "${ZSH_VERSION}" ] &&
  typeset -U PATH path CDPATH cdpath FPATH fpath MANPATH manpath &&
  export PATH path CDPATH cdpath FPATH fpath MANPATH manpath

# powerlevel10k prompt
# customize prompt via `p10k configure` or edit `~/.p10k.zsh`
# if the theme is powerlevel10k,
[ "${ZSH_THEME}" = 'powerlevel10k/powerlevel10k' ] &&
  # and there is a file at ~/.p10k.zsh,
  [ -r "${HOME}/.p10k.zsh" ] &&
  # then source it
  . "${HOME}/.p10k.zsh"
