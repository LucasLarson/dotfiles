#!/usr/bin/env sh

clear
printf '   .\x5f\x5f       .\x5f\x5f  \x5f\x5f\n'
printf '   \x7c\x5f\x5f\x7c \x5f\x5f\x5f\x5f \x7c\x5f\x5f\x7c\x2f  \x7c\x5f\n'
printf '   \x7c  \x7c\x2f    \x5c\x7c  \x5c   \x5f\x5f\x5c\n'
printf '   \x7c  \x7c   \x7c  \x5c  \x7c\x7c  \x7c\n'
printf '   \x7c\x5f\x5f\x7c\x5f\x5f\x5f\x7c'
printf '  \x2f\x5f\x5f\x7c\x7c\x5f\x5f\x7c\n'
printf '           \x5c\x2f\n\n'
printf ' Alpine Linux setup\n'
sleep 1
printf '  a Lucas Larson production\n\n'
sleep 1

# unset `$PS4`
# if this quaternary prompt string is already unset, then
# set it to the POSIX default: `+ `
# https://opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
PS4_temporary=${PS4:-+ }
unset PS4

# pacman
# https://askubuntu.com/a/459425
# https://stackoverflow.com/a/26314887
# force refresh with `-yy`
[ "$(awk -F= '/^NAME/{print $2}' /etc/os-release 2>/dev/null | tr -d '"')" = "Arch Linux" ] && pacman --sync -yy

# apk
command -v apk >/dev/null 2>&1 || (
  # https://github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version/8901950#wiki-body
  wget --output-document - https://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz apk.static
  ./apk.static add apk-tools
)

# configure repositories
printf 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n' >/etc/apk/repositories
printf 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n' >>/etc/apk/repositories

# update
printf '\nupdating Alpine Linux repositories...\n'
apk update --verbose --progress
apk upgrade --verbose --progress

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Man_pages
# man-pages adds `man0`, `man2`, man4`, `man6` to `/usr/share/man/`
{ [ -d /usr/share/man/man0 ] &&
  [ -d /usr/share/man/man2 ] &&
  [ -d /usr/share/man/man4 ] &&
  [ -d /usr/share/man/man6 ]; } || (
  printf '\ninstalling man pages...\n'
  apk add man-pages
)
command -v mandoc >/dev/null 2>&1 || (
  printf '\ninstalling mandoc for man pages...\n'
  apk add mandoc mandoc-doc
)
command -v less >/dev/null 2>&1 || (
  printf '\ninstalling less to read man pages...\n'
  apk add less less-doc
)

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Shell_.40_commandline
# https://web.archive.org/web/20210218201739id_/web.archive.org/screenshot/docs.google.com/document/d/10-8wjANQGbG43XZ0wN57M1RYOLUwu9RZATNe9vJQYKw/mobilebasic
# https://wiki.alpinelinux.org/w/index.php?oldid=18038&title=Alpine_newbie_apk_packages#coreutils_libc_and_utmps_in_alpine
apk add coreutils coreutils-doc
{ [ -x /usr/bin/coreutils ] &&
  [ "$(command find -version | head -n1 | awk '{print $3}' | tr -d '()')" = findutils ]; } || (
  printf '\ninstalling Linux utilities...\n'
)
apk add util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc wget wget-doc curl curl-doc openssl openssl-doc sudo sudo-doc sed sed-doc attr attr-doc dialog dialog-doc bash bash-doc bash-completion bash-completion-doc readline readline-doc
{
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/main\n'
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/community\n'
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/testing\n'
} >>/etc/apk/repositories
apk update

# ssh
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
[ -d /etc/ssh ] || (
  printf '\ninstalling OpenSSH...\n'
  apk add openssh openssh-doc
)
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
[ -x /usr/bin/gpg2 ] || (
  apk add gnupg gnupg-doc
)

# git
command -v git >/dev/null 2>&1 || (
  printf '\ninstalling Git...\n'
  apk add git git-doc
)

# git add --patch
[ -x /usr/libexec/git-core/git-add--interactive ] || (
  # https://stackoverflow.com/a/57632778
  apk add git-perl
)

# time zone
printf '\nupdating time zone information...\n'
apk add --no-cache tzdata tzdata-doc
[ -r /usr/share/zoneinfo/America/New_York ] &&
  cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York\n' >/etc/timezone

# python
printf '\nchecking Python installation...\n'
command -v python >/dev/null 2>&1 || (
  printf '\ninstalling Python 2 and Python 3...\n'
  apk add python2 python2-doc python3 python3-doc
)

# pip
command -v pip >/dev/null 2>&1 || (
  printf '\ninstalling pip...\n' && sleep 3
  printf 'this may take a while...\n'
  curl https://web.archive.org/web/20210420182646id_/bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
)

# mackup
command -v mackup >/dev/null 2>&1 || (
  printf '\ninstalling mackup...\n'
  pip install --upgrade mackup
)

# zsh
command -v zsh >/dev/null 2>&1 || (
  printf '\ninstalling Zsh...\n'
  apk add zsh zsh-doc
)

# chsh
# part of shadow on Alpine Linux
command -v chsh >/dev/null 2>&1 || (
  apk add shadow shadow-doc
)

# Oh My Zsh
command -v omz >/dev/null 2>&1 || [ -d "${HOME}/.oh-my-zsh" ] || (
  printf 'installing Oh My Zsh...\n'
  sh -c "$(wget https://web.archive.org/web/20201211072817id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh --output-document -)" "" --unattended --keep-zshrc
)

# update, repair everything again before close
printf '\nupdating...\n'
apk update --verbose --progress
printf '\nupgrading...\n'
apk upgrade --verbose --progress
printf '\nrepairing and resolving dependencies...\n'
apk fix --verbose --verbose --depends --progress
printf '\nverifying installations...\n'
apk verify --verbose --verbose --progress && printf 'verified.\n'
command -v pip >/dev/null 2>&1 && (
  printf '\nupdating Python\xe2\x80\x99s package manager...\n'
  python3 -m pip install --upgrade pip
)

# cleanup
printf '\n\ncleaning up temporary installation files and performing housekeeping...\n'
[ -w apk.static ] && rm apk.static
[ -w get-pip.py ] && rm get-pip.py
[ -w setup ] && rm setup

# message of the day
[ -e /etc/motd.bak ] || cp /etc/motd /etc/motd.bak
printf '' >/etc/motd

# delete thumbnail cache files
find -- . -type f \( \
  -name '.DS_Store' -or \
  -name 'Desktop.ini' -or \
  -name 'Thumbs.db' -or \
  -name 'desktop.ini' -or \
  -name 'thumbs.db' \
  \) \
  -delete 2>/dev/null

# delete empty, writable, zero-length files
# except those within `.git/` directories
# and those with specific names
# https://stackoverflow.com/a/64863398
find -- . -type f -writable -size 0 \( \
  -not -path '*.git/*' -and \
  -not -name "$(printf 'Icon\xd\xa')" -and \
  -not -name '*LOCK' -and \
  -not -name '*empty*' -and \
  -not -name '*hushlogin' -and \
  -not -name '*ignore' -and \
  -not -name '*journal' -and \
  -not -name '*lock' -and \
  -not -name '*lockfile' -and \
  -not -name '.dirstamp' -and \
  -not -name '.gitkeep' -and \
  -not -name '.gitmodules' -and \
  -not -name '.keep' -and \
  -not -name '.sudo_as_admin_successful' -and \
  -not -name '.watchmanconfig' -and \
  -not -name '__init__.py' -and \
  -not -name 'favicon.*' \
  \) \
  -delete 2>/dev/null

# delete empty directories recursively
# but skip Git-specific and `/.well-known/` directories
# https://stackoverflow.com/q/4210042#comment38334264_4210072
find -- . -type d -empty \( \
  -not -path '*.git/*' -and \
  -not -name '.well-known' \
  \) \
  -delete 2>/dev/null

# done
printf '\ninitialization complete\n'
sleep 0.5
printf '\nrestarting...\n'
sleep 1

# restore `$PS4`
PS4=${PS4_temporary}
unset PS4_temporary

printf '\ndone!\n'
exit
