# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/LucasLarson/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# powerlevel10k via https://github.com/romkatv/powerlevel10k/blob/48c6ff4701eaf1a3c3570b01c09c30e6ed912a56/README.md#oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
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
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# UPDATE: as of 2020-03-04, this was too costly for whatever potential benefits
#         I’m seeking, and there is no “remember this answer of mine for next
#         time” option.
#         $ `brew remove rbenv` returned `correct 'rbenv' to '.rbenv' [nyae]?`
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Editor
# Set preferred editor if it is available
if which nvim > /dev/null; then
  export EDITOR="nvim"
elif which vim > /dev/null; then
  export EDITOR="vim"
elif which vi > /dev/null; then
  export EDITOR="vi"
else
  export EDITOR="nano"
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Homebrew
# https://github.com/Homebrew/brew/blob/a5b6c5f2621298c879aa205754ae01d5417572d9/Library/Homebrew/diagnostic.rb#L432-L435
export PATH="/usr/local/sbin:$PATH"


# npm without sudo
# https://github.com/sindresorhus/guides/blob/285270f06e117c7e0a6b6e51eca6e488d9d7c44d/npm-global-without-sudo.md#3-ensure-npm-will-find-installed-binaries-and-man-pages
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$NPM_PACKAGES/bin:$PATH"
unset MANPATH # delete if you already modified MANPATH elsewhere
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"


# RVM and rbenv are incompatible and shell references to RVM have to be removed
# https://github.com/rbenv/rbenv/blob/577f04653df2289f492d4cd9ea3e9d441281f317/README.md#installation
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"



export DOTFILES="$HOME/Dropbox/Mackup" # ∃ also alias dotfiles thereto



# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi


# C, C++ headers
# https://apple.stackexchange.com/a/372600
export CPATH=`xcrun --show-sdk-path`/usr/include


# Flutter
# https://github.com/flutter/website/blob/e5f725c7ff39d2cb5356f2ccd998e560c4060a4a/src/docs/get-started/install/_path-mac.md#user-content-update-your-path
export PATH="$PATH:$HOME/Code/Flutter/bin"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"


# rbenv
# https://hackernoon.com/the-only-sane-way-to-setup-fastlane-on-a-mac-4a14cb8549c8#6a04
# export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
