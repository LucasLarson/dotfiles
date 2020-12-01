#!/usr/bin/env zsh

update=1
clear && clear


printf '                 .___       __\n'
printf ' __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n'
printf '\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n'
printf '\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n'
printf '\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n'
printf '      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n'
printf ' a Lucas Larson production\n\n'

sleep 1.0

if [[ Darwin == "$(uname)" ]]; then

printf '\n\xf0\x9f\x93\xa1 verifying network connectivity...\n'
sleep 0.5
(ping -q -i1 -c1 one.one.one.one &>/dev/null && ping -q -i1 -c1 8.8.8.8 &>/dev/null) || (printf 'No internet connection was detected.\nAborting update.\n' && return $update)

printf '\xf0\x9f\x8d\xba checking for Homebrew updates...\n'
brew update
brew upgrade
brew upgrade --cask


xcrun simctl delete unavailable


omz update


rustup update


npm install npm --global
npm update --global --verbose


apm upgrade --no-confirm


gem update --system
gem update
rbenv rehash


printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n'
python -m pip install --upgrade pip

printf '\n\xf0\x9f\x90\x8d generating list of outdated Python packages...\n'
pip list --outdated --format freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install --upgrade

printf '\n\xf0\x9f\x90\x8d upgrading all Python packages...\n'
pip install --upgrade $(pip freeze | cut -d '=' -f 1)
pyenv rehash


fi


source ~/.zshrc && rehash


unset update
printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "$update"


exec zsh
