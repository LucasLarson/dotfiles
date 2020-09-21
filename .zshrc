#!/usr/bin/env zsh

# Powerlevel10k instant prompt
# https://github.com/romkatv/powerlevel10k/blob/d394a4e038e494354cbdb68aeaebc05e7d0788fa/README.md#how-do-i-enable-instant-prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# powerlevel10k
# https://github.com/romkatv/powerlevel10k/blob/48c6ff4701eaf1a3c3570b01c09c30e6ed912a56/README.md#oh-my-zsh
# ZSH_THEME
if [[ "$(uname)" =~ Darwin && -d $ZSH/custom/themes/powerlevel10k ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME="robbyrussell"
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst awaiting completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# https://unix.stackexchange.com/a/273863
export HISTSIZE=2147483647
export SAVEHIST=$HISTSIZE

# Use a custom folder other than $ZSH/custom
# set to $DOTFILES for easier submodule additions
if [[ $DOTFILES/.oh-my-zsh/custom -ef $ZSH/custom ]]; then
  ZSH_CUSTOM=$DOTFILES/.oh-my-zsh/custom
fi

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  gunstage
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh



# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8


# Editor
# Set preferred editor if it is available
# https://stackoverflow.com/a/14755066
# https://github.com/wililupy/snapd/commit/0573e7b34914c9e9fed9e2a84687106438dda19c
if command -v nvim > /dev/null 2>&1; then
  EDITOR="nvim"
elif command -v vim > /dev/null 2>&1; then
  EDITOR="vim"
elif command -v vi > /dev/null 2>&1; then
  EDITOR="vi"
else
  EDITOR="nano"
fi
export EDITOR
# https://github.com/koalaman/shellcheck/wiki/SC2139/db553bf16fcb86b2cdc77b835e75b9121eacc429#this-expands-when-defined-not-when-used-consider-escaping
alias editor='$EDITOR'
alias edit="editor"



# Compilation flags
# export ARCHFLAGS="-arch x86_64"


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# GPG signing with macOS-compatible Linux
# https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key#telling-git-about-your-gpg-key-2
# https://reddit.com/comments/dk53ow/_/f50146x
export GPG_TTY=$TTY


# Homebrew
# https://github.com/Homebrew/brew/blob/a5b6c5f2621298c879aa205754ae01d5417572d9/Library/Homebrew/diagnostic.rb#L432-L435
[[ -d /usr/local/sbin ]] && PATH="/usr/local/sbin:$PATH"


# grep
# use latest via Homebrew but without the `g` prefix
# https://github.com/Homebrew/homebrew-core/blob/ba7a70f2947b72566720801afee56cb862fcd783/Formula/grep.rb#L43-L46
[[ -d /usr/local/opt/grep/libexec/gnubin ]] && PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"

# make
# use latest via Homebrew but without the `g` prefix
# https://github.com/Homebrew/homebrew-core/blob/9591758fd8a565abf98d13ffd87c66e5e12ad579/Formula/make.rb#L37-L41
[[ -d /usr/local/opt/make/libexec/gnubin ]] && PATH="/usr/local/opt/make/libexec/gnubin:$PATH"


# npm without sudo
# https://github.com/sindresorhus/guides/blob/285270f06e117c7e0a6b6e51eca6e488d9d7c44d/npm-global-without-sudo.md#3-ensure-npm-will-find-installed-binaries-and-man-pages
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$NPM_PACKAGES/bin:$PATH"
unset MANPATH # delete if you already modified MANPATH elsewhere
if [[ $manpath ]]; then
  export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
fi


# RVM and rbenv are incompatible and shell references to RVM have to be removed
# https://github.com/rbenv/rbenv/blob/577f04653df2289f492d4cd9ea3e9d441281f317/README.md#installation
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"


# dotfiles
# set to where they are syncing if it exists, or else use the default: $HOME
# https://github.com/ohmyzsh/ohmyzsh/blob/5ffc0d036c587741fd25092e7809dad2b00b3677/oh-my-zsh.sh#L20-L24
# https://gnu.org/software/bash/manual/bash#Bash-Conditional-Expressions
# https://stackoverflow.com/a/13408590
if [ -z "$DOTFILES" ] || [ -e "$HOME/Dropbox/Mackup" ]; then
  export DOTFILES="$HOME/Dropbox/Mackup"
else
  export DOTFILES="$HOME"
fi
if [ -d "$HOME/Code/ Template" ] || [ -d "$HOME/Code/Template" ]; then
  export TEMPLATE="$HOME/Code/ Template"
fi

# customize Oh My Zsh completion dots
# https://git.io/completion-dots-in-.zshrc
expand-or-complete-with-dots () {
  print -Pn "%F{red}...%f"
  zle expand-or-complete
  zle redisplay
}


# pyenv
command -v pyenv > /dev/null 2>&1 && eval "$(pyenv init -)"


# C, C++ headers
# https://apple.stackexchange.com/a/372600
if command -v xcrun > /dev/null 2>&1; then
  CPATH=$(xcrun --show-sdk-path)/usr/include
  export CPATH
fi


# Flutter
# https://github.com/flutter/website/blob/e5f725c7ff39d2cb5356f2ccd998e560c4060a4a/src/docs/get-started/install/_path-mac.md#user-content-update-your-path
export PATH="$PATH:$HOME/Code/Flutter/bin"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"


# rbenv
# https://hackernoon.com/the-only-sane-way-to-setup-fastlane-on-a-mac-4a14cb8549c8#6a04
# export PATH="$HOME/.rbenv/bin:$PATH"
command -v rbenv > /dev/null 2>&1 && eval "$(rbenv init -)"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
