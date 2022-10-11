#!/usr/bin/env sh

# init
# Author: Lucas Larson
#
# Description: bootstrap a new machine
# Assumptions: installation target is one of Arch Linux or Alpine Linux

# Alpine Linux
# wget --continue --server-response 'https://lucaslarson.net/init.sh'
# apk add --verbose "$@"

# Arch Linux
# curl --remote-name --location 'https://lucaslarson.net/init.sh'
# pacman --sync --verbose --noconfirm "$@"

if command -v -- wget >/dev/null 2>&1; then
  command wget --continue --server-response 'https://lucaslarson.net/init.sh'
else
  command curl --remote-name --location 'https://lucaslarson.net/init.sh'
fi

if command -v -- apk >/dev/null 2>&1; then
  alias install='command apk add --verbose'
elif command -v -- pacman >/dev/null 2>&1; then
  alias install='command pacman --sync --verbose --noconfirm'
elif command -v -- apt-get >/dev/null 2>&1; then
  alias install='command apt-get install --verbose --show-progress --assume-yes'
fi

clear
printf '   .\137\137       .\137\137  \137\137\n' 2>/dev/null
printf '   \174\137\137\174 \137\137\137\137 \174\137\137\174\057  \174\137\n' 2>/dev/null
printf '   \174  \174\057    \134\174  \134   \137\137\134\n' 2>/dev/null
printf '   \174  \174   \174  \134  \174\174  \174\n' 2>/dev/null
printf '   \174\137\137\174\137\137\137\174' 2>/dev/null
printf '  \057\137\137\174\174\137\137\174\n' 2>/dev/null
printf '           \134\057\n\n' 2>/dev/null
printf '        Linux setup\n' 2>/dev/null
command sleep 1
printf '  a Lucas Larson production\n\n' 2>/dev/null
command sleep 1

# start from `$HOME`
cd -- "${HOME-}" ||
  exit 1

# unset `$PS4`
# if this quaternary prompt string is already unset, then
# set it to the POSIX default: `+ `
# https://opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
ps4_temporary="${PS4:-+ }"
unset -- PS4
set -o xtrace

# pacman
# https://askubuntu.com/a/459425
# https://stackoverflow.com/a/26314887
test "$(command awk -F '=' '/^NAME/{print $2}' '/etc/os-release' 2>/dev/null | command tr -d '"')" = 'Arch Linux' && {
  command pacman --sync --refresh --refresh ||
    # https://wiki.archlinux.org/?oldid=667441#Installing_packages
    command pacman --sync --refresh --upgrades 2>/dev/null
}

# apk
command -v -- apk >/dev/null 2>&1 || {
  # trust apk only if it matches a known checksum
  { set +o xtrace; } 2>/dev/null
  printf 'verifying apk tools integrity...\n' 2>/dev/null
  set -o xtrace
  test "$(command curl --fail --silent --location 'https://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk' | command sha256sum)" != '6b3f874c374509e845633c9bb76f21847d0c905dae3e5df58c1809184cef8260  -'
} || {
  # https://web.archive.org/web/20201127045648id_/github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version#wiki-body
  command wget --output-document - 'https://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk' |
    command tar --extract --gzip 'apk.static'
  ./apk.static add apk-tools
}

# configure only main and community repositories at first
{
  printf 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n'
  printf 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n'
} >'/etc/apk/repositories'

# update
{ set +o xtrace; } 2>/dev/null
printf 'updating Alpine Linux repositories...\n' 2>/dev/null
set -o xtrace
command apk update --verbose --progress
command apk upgrade --verbose --progress

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Man_pages
# man-pages adds `man0`, `man2`, man4`, `man6` to `/usr/share/man/`
{ test -d '/usr/share/man/man0' &&
  test -d '/usr/share/man/man2' &&
  test -d '/usr/share/man/man4' &&
  test -d '/usr/share/man/man6'; } || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing man pages...\n' 2>/dev/null
  set -o xtrace
  install man-pages
}
command -v -- mandoc >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing mandoc for man pages...\n' 2>/dev/null
  set -o xtrace
  install mandoc mandoc-doc
}
command -v -- less >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing less to read man pages...\n' 2>/dev/null
  set -o xtrace
  install less less-doc
}

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Shell_.40_commandline
# https://web.archive.org/web/20210218201739id_/web.archive.org/screenshot/docs.google.com/document/d/10-8wjANQGbG43XZ0wN57M1RYOLUwu9RZATNe9vJQYKw/mobilebasic
# https://wiki.alpinelinux.org/w/index.php?oldid=18038&title=Alpine_newbie_apk_packages#coreutils_libc_and_utmps_in_alpine
install coreutils coreutils-doc
{ test -x '/usr/bin/coreutils' &&
  test "$(command find --version 2>/dev/null | command head -n 1 | command awk '{print $3}' | command tr -d '()')" = 'findutils'; } || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing Linux utilities...\n' 2>/dev/null
  set -o xtrace
}
install util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc wget wget-doc curl curl-doc openssl openssl-doc sudo sudo-doc sed sed-doc attr attr-doc dialog dialog-doc bash bash-doc bash-completion bash-completion-doc readline readline-doc
{
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/main\n'
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/community\n'
  printf 'https://dl-cdn.alpinelinux.org/alpine/edge/testing\n'
} >>'/etc/apk/repositories'
command apk update

# ssh
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
test -d '/etc/ssh' || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing OpenSSH...\n' 2>/dev/null
  set -o xtrace
  install openssh openssh-doc
}

# gpg
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
test -x '/usr/bin/gpg2' || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing GPG...\n' 2>/dev/null
  set -o xtrace
  install gnupg gnupg-doc
}

# git
command -v -- git >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing Git...\n' 2>/dev/null
  set -o xtrace
  install git git-doc
}

# git add --patch
test -x '/usr/libexec/git-core/git-add--interactive' || {
  # https://stackoverflow.com/a/57632778
  install git-perl
}

# git user
command git config --global --get user.name >/dev/null 2>&1 || {
  command git config --global user.name 'Lucas Larson'
}

# git default branch
command git config --global --get init.defaultBranch >/dev/null 2>&1 || {
  command git config --global init.defaultBranch 'main'
}

# time zone
{ set +o xtrace; } 2>/dev/null
printf 'updating time zone information...\n' 2>/dev/null
set -o xtrace
install --no-cache tzdata tzdata-doc
test -r '/usr/share/zoneinfo/America/New_York' &&
  cp -- '/usr/share/zoneinfo/America/New_York' '/etc/localtime'
printf 'America/New_York\n' >'/etc/timezone'

# python
{ set +o xtrace; } 2>/dev/null
printf 'checking Python installation...\n' 2>/dev/null
set -o xtrace
command -v -- python >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing Python...\n' 2>/dev/null
  set -o xtrace
  install python3 python3-doc
}

# pip
{ set +o xtrace; } 2>/dev/null
printf 'checking Python package manager installation...\n' 2>/dev/null
set -o xtrace
command -v -- pip >/dev/null 2>&1 && {
  { set +o xtrace; } 2>/dev/null
  printf 'updating pip...\n' 2>/dev/null
  set -o xtrace
  command python3 -m pip install --upgrade pip 2>/dev/null
} || {
  { set +o xtrace; } 2>/dev/null
  {
    printf 'installing pip...\n'
    printf 'verifying integrity of pip bootstrap file...\n'
  } 2>/dev/null
  set -o xtrace
  test "$(command curl --fail --silent --location 'https://web.archive.org/web/20210420182646id_/bootstrap.pypa.io/get-pip.py' | command sha256sum)" != 'e03eb8a33d3b441ff484c56a436ff10680479d4bd14e59268e67977ed40904de  -'
} || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing pip using bootstrap...\n' 2>/dev/null
  set -o xtrace
  command curl 'https://web.archive.org/web/20210420182646id_/bootstrap.pypa.io/get-pip.py' -o ./get-pip.py
  { set +o xtrace; } 2>/dev/null
  printf 'this may take a while...\n' 2>/dev/null
  set -o xtrace
  command python3 -v ./get-pip.py
}

# mackup
command -v -- mackup >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing mackup...\n' 2>/dev/null
  set -o xtrace
  command pip install --upgrade mackup
}

# zsh
command -v -- zsh >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing Zsh...\n' 2>/dev/null
  set -o xtrace
  install zsh zsh-doc
}

# chsh
# part of shadow on Alpine Linux
command -v -- chsh >/dev/null 2>&1 || {
  install shadow shadow-doc
}

# Oh My Zsh
command -v -- omz >/dev/null 2>&1 ||
  test -d "${ZSH:="${HOME-}"/.oh-my-zsh}" ||
  test "$(command curl --fail --silent --location 'https://web.archive.org/web/20210520175616id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/02d07f3e3dba0d50b1d907a8062bbaca18f88478/tools/install.sh' | command sha256sum)" != 'b6af836b2662f21081091e0bd851d92b2507abb94ece340b663db7e4019f8c7c  -' || {
  { set +o xtrace; } 2>/dev/null
  printf 'installing Oh My Zsh...\n' 2>/dev/null
  set -o xtrace
  sh -c "$(command wget 'https://web.archive.org/web/20210520175616id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/02d07f3e3dba0d50b1d907a8062bbaca18f88478/tools/install.sh' --output-document -)" "" --unattended --keep-zshrc
}

# update, repair everything again before close
{ set +o xtrace; } 2>/dev/null
printf 'updating...\n' 2>/dev/null
set -o xtrace
command apk update --verbose --verbose --progress

{ set +o xtrace; } 2>/dev/null
printf 'upgrading...\n' 2>/dev/null
set -o xtrace
command apk upgrade --verbose --verbose --progress

{ set +o xtrace; } 2>/dev/null
printf 'repairing and resolving dependencies...\n' 2>/dev/null
set -o xtrace
command apk fix --verbose --verbose --depends --progress

{ set +o xtrace; } 2>/dev/null
printf 'verifying installations...\n' 2>/dev/null
set -o xtrace
command apk verify --verbose --verbose --progress && {
  { set +o xtrace; } 2>/dev/null
  printf 'verified\n' 2>/dev/null
  set -o xtrace
}

# cleanup
{ set +o xtrace; } 2>/dev/null
printf 'cleaning up temporary installation files and performing housekeeping...\n' 2>/dev/null
set -o xtrace
test -w ./apk.static &&
  rm ./apk.static
test -w ./get-pip.py &&
  rm ./get-pip.py
test -w ./setup &&
  rm ./setup

# message of the day
test -s '/etc/motd' &&
  cp -- '/etc/motd' '/etc/motd-'"$(command date '+%Y%m%d_%s')" &&
  printf '' >'/etc/motd'

# delete thumbnail cache files
command find -- . \
  -type f \
  '(' \
  -name '.DS_Store' -o \
  -name 'Desktop.ini' -o \
  -name 'Thumbs.db' -o \
  -name 'desktop.ini' -o \
  -name 'thumbs.db' \
  ')' \
  -delete 2>/dev/null

# delete empty, writable, zero-length files
# except those within `.git/` directories
# and those with specific names
command find -- . \
  -type f \
  -writable \
  -size 0 \
  '(' \
  ! -path '*.git/*' \
  ! -path '*example*' \
  ! -path '*sample*' \
  ! -path '*template*' \
  ! -path '*test*' \
  ! -name "$(printf 'Icon\0xd\0xa')" \
  ! -name '*LOCK' \
  ! -name '*empty*' \
  ! -name '*hushlogin' \
  ! -name '*ignore' \
  ! -name '*journal' \
  ! -name '*lock' \
  ! -name '*lockfile' \
  ! -name '.dirstamp' \
  ! -name '.gitkeep' \
  ! -name '.gitmodules' \
  ! -name '.keep' \
  ! -name '.sudo_as_admin_successful' \
  ! -name '.watchmanconfig' \
  ! -name '__init__.py' \
  ! -name 'favicon.*' \
  ')' \
  -delete 2>/dev/null

# delete empty directories recursively
# but skip Git-specific and `/.well-known/` directories
command find -- . -type d -empty \
  ! -path '*.git/*' \
  ! -name '.well-known' \
  -delete 2>/dev/null

# if sed installation was successful, and
# if zsh is available, replace bash, ash, and sh with zsh in `/etc/passwd`
command -v -- zsh >/dev/null 2>&1 &&
  command grep -E -e '/bin/b?a?sh' '/etc/passwd' 2>&1 &&
  cp -- '/etc/passwd' '/etc/passwd-'"$(command date '+%Y%m%d_%s')" &&
  # `-E` for extended regex searching for `/bin/ash` and `/bin/sh`
  # `-i` for in-place editing
  command sed -E -i -e "s|/bin/b?a?sh$|$(command -v -- zsh)|" '/etc/passwd'

# done
{ set +euvx; } 2>/dev/null
printf 'installation complete\n' 2>/dev/null
command sleep 1
printf 'exiting to apply updates...\n' 2>/dev/null

# restore `$PS4`
PS4="${ps4_temporary:-+ }"
unset -- ps4_temporary

{
  printf '\n'
  printf 'done!\n'
} 2>/dev/null

exit
