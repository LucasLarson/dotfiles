#!/usr/bin/env sh

# init
# Author: Lucas Larson
#
# Description: bootstrap a new machine
# Assumptions: installation target is one of Arch Linux or Alpine Linux

# Alpine Linux
# wget -O- https://lucaslarson.net/init.sh | sh

# Arch Linux
# curl https://lucaslarson.net/init.sh | sh

if command -v -- apk >/dev/null 2>&1; then
  alias install='command apk add --verbose'
elif command -v -- pacman >/dev/null 2>&1; then
  alias install='command pacman --sync --verbose --noconfirm'
elif command -v -- apt-get >/dev/null 2>&1; then
  alias install='command apt-get install --verbose --show-progress --assume-yes'
fi

clear
printf -- '   .\137\137       .\137\137  \137\137\n' 2>/dev/null
printf -- '   \174\137\137\174 \137\137\137\137 \174\137\137\174\057  \174\137\n' 2>/dev/null
printf -- '   \174  \174\057    \134\174  \134   \137\137\134\n' 2>/dev/null
printf -- '   \174  \174   \174  \134  \174\174  \174\n' 2>/dev/null
printf -- '   \174\137\137\174\137\137\137\174' 2>/dev/null
printf -- '  \057\137\137\174\174\137\137\174\n' 2>/dev/null
printf -- '           \134\057\n\n' 2>/dev/null
printf -- '        Linux setup\n' 2>/dev/null
command sleep 1
printf -- '  a Lucas Larson production\n\n' 2>/dev/null
command sleep 1

# start from `$HOME`
cd "${HOME-}" ||
  exit 1

# save `date` for backup files
now="$(command date -- '+%Y%m%d')"_"$(command awk -- 'BEGIN {srand(); print srand()}')"

# unset `$PS4`
# if this quaternary prompt string is already unset, then
# set it to the POSIX default: `+ `
# https://opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
ps4_temporary="${PS4:-+ }"
unset -v -- PS4
set -o xtrace

# pacman
# https://askubuntu.com/a/459425
command -v -- pacman >/dev/null 2>&1 && {
  command pacman --sync --refresh --refresh ||
    # https://wiki.archlinux.org/?oldid=667441#Installing_packages
    command pacman --sync --refresh --upgrades 2>/dev/null
}

# apk
command -v -- apk >/dev/null 2>&1 || {
  # trust apk only if it matches a known checksum
  { set +o xtrace; } 2>/dev/null
  printf -- 'verifying apk tools integrity...\n' 2>/dev/null
  set -o xtrace
  test "$(command wget --output-document=- --quiet -- 'https://web.archive.org/web/20221114182828id_/dl-cdn.alpinelinux.org/alpine/v3.16/main/x86/apk-tools-static-2.12.9-r3.apk' | command cksum)" != '3008894084 1363723'
} || {
  # https://web.archive.org/web/20201127045648id_/github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version#wiki-body
  command wget --output-document=- -- 'https://web.archive.org/web/20221114182828id_/dl-cdn.alpinelinux.org/alpine/v3.16/main/x86/apk-tools-static-2.12.9-r3.apk' |
    command tar --extract --gzip --strip-components=1 --verbose -- sbin/apk.static &&
    ./apk.static add apk-tools &&
    command rm -- ./apk.static
}

# configure only main and community repositories at first
{
  printf -- 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n'
  printf -- 'https://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n'
} >'/etc/apk/repositories'

# update
{ set +o xtrace; } 2>/dev/null
printf -- 'updating Alpine Linux repositories...\n' 2>/dev/null
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
  printf -- 'installing man pages...\n' 2>/dev/null
  set -o xtrace
  install man-pages
}
command -v -- mandoc >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing mandoc for man pages...\n' 2>/dev/null
  set -o xtrace
  install mandoc mandoc-doc
}
command -v -- less >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing less to read man pages...\n' 2>/dev/null
  set -o xtrace
  install less less-doc
}

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Shell_.40_commandline
# https://web.archive.org/web/20210218201739id_/web.archive.org/screenshot/docs.google.com/document/d/10-8wjANQGbG43XZ0wN57M1RYOLUwu9RZATNe9vJQYKw/mobilebasic
# https://wiki.alpinelinux.org/w/index.php?oldid=18038&title=Alpine_newbie_apk_packages#coreutils_libc_and_utmps_in_alpine
install coreutils coreutils-doc
{ test -x '/usr/bin/coreutils' &&
  command find --version >/dev/null 2>&1 | command grep -q -e 'findutils'; } || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing Linux utilities...\n' 2>/dev/null
  set -o xtrace
}
install util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc wget wget-doc curl curl-doc openssl openssl-doc sudo sudo-doc sed sed-doc attr attr-doc dialog dialog-doc bash bash-doc bash-completion bash-completion-doc readline readline-doc
{
  printf -- 'https://dl-cdn.alpinelinux.org/alpine/edge/main\n'
  printf -- 'https://dl-cdn.alpinelinux.org/alpine/edge/community\n'
  printf -- 'https://dl-cdn.alpinelinux.org/alpine/edge/testing\n'
} >>'/etc/apk/repositories'
command apk update

# ssh
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
test -d '/etc/ssh' || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing OpenSSH...\n' 2>/dev/null
  set -o xtrace
  install openssh openssh-doc
}

# gpg
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
test -x '/usr/bin/gpg2' || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing GPG...\n' 2>/dev/null
  set -o xtrace
  install gnupg gnupg-doc
}

# git
command -v -- git >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing Git...\n' 2>/dev/null
  set -o xtrace
  install git git-doc
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
printf -- 'updating time zone information...\n' 2>/dev/null
set -o xtrace
install --no-cache tzdata tzdata-doc

# python
{ set +o xtrace; } 2>/dev/null
printf -- 'checking Python installation...\n' 2>/dev/null
set -o xtrace
command -v -- python >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing Python...\n' 2>/dev/null
  set -o xtrace
  install python3 python3-doc
}

# pip
{ set +o xtrace; } 2>/dev/null
printf -- 'checking Python package manager installation...\n' 2>/dev/null
set -o xtrace
command -v -- pip >/dev/null 2>&1 && {
  { set +o xtrace; } 2>/dev/null
  printf -- 'updating pip...\n' 2>/dev/null
  set -o xtrace
  command python3 -m pip install --upgrade pip 2>/dev/null
} || {
  { set +o xtrace; } 2>/dev/null
  {
    printf -- 'installing pip...\n'
    printf -- 'verifying integrity of pip bootstrap file...\n'
  } 2>/dev/null
  set -o xtrace
  test "$(command curl --fail --silent --location 'https://web.archive.org/web/20221114002029id_/bootstrap.pypa.io/get-pip.py' | command cksum)" != '3397773170 2569500'
} || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing pip using bootstrap...\n' 2>/dev/null
  printf -- 'this may take a while...\n' 2>/dev/null
  set -o xtrace
  command curl 'https://web.archive.org/web/20221114002029id_/bootstrap.pypa.io/get-pip.py' | command python3
}

# mackup
command -v -- mackup >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing mackup...\n' 2>/dev/null
  set -o xtrace
  command pip install --upgrade mackup
}

# zsh
command -v -- zsh >/dev/null 2>&1 || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing Zsh...\n' 2>/dev/null
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
  test "$(command curl --fail --silent --location 'https://web.archive.org/web/20210520175616id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/02d07f3e3dba0d50b1d907a8062bbaca18f88478/tools/install.sh' | command cksum)" != '1976015298 9942' || {
  { set +o xtrace; } 2>/dev/null
  printf -- 'installing Oh My Zsh...\n' 2>/dev/null
  if command -v -- wget >/dev/null 2>&1; then
    set -o xtrace
    sh -c "$(command wget 'https://web.archive.org/web/20210520175616id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/02d07f3e3dba0d50b1d907a8062bbaca18f88478/tools/install.sh' --output-document=-)" "" --unattended --keep-zshrc
  elif command -v -- curl >/dev/null 2>&1; then
    set -o xtrace
    sh -c "$(curl --location 'https://web.archive.org/web/20210520175616id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/02d07f3e3dba0d50b1d907a8062bbaca18f88478/tools/install.sh')" --unattended --keep-zshrc
  fi
  { set +o xtrace; } 2>/dev/null
}

# update, repair everything again before close
{ set +o xtrace; } 2>/dev/null
printf -- 'updating...\n' 2>/dev/null
set -o xtrace
command apk update --verbose --verbose --progress

{ set +o xtrace; } 2>/dev/null
printf -- 'upgrading...\n' 2>/dev/null
set -o xtrace
command apk upgrade --verbose --progress

{ set +o xtrace; } 2>/dev/null
printf -- 'repairing and resolving dependencies...\n' 2>/dev/null
set -o xtrace
command apk fix --verbose --verbose --depends --progress

{ set +o xtrace; } 2>/dev/null
printf -- 'verifying installations...\n' 2>/dev/null
set -o xtrace
command apk verify --verbose --verbose --progress && {
  { set +o xtrace; } 2>/dev/null
  printf -- 'verified\n' 2>/dev/null
  set -o xtrace
}

# cleanup
{ set +o xtrace; } 2>/dev/null
printf -- 'cleaning up temporary installation files and performing housekeeping...\n' 2>/dev/null
set -o xtrace

# message of the day
test -w '/etc/motd' &&
  command cp -- '/etc/motd' '/etc/motd-'"${now-}" &&
  printf -- '' >'/etc/motd'

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
  -delete

# delete empty files
# except those within `.git/` directories
# and those with specific names
command find -- . \
  -type f \
  -size 0 \
  ! -path "${DOTFILES-}"'/Library/*' \
  ! -path "${HOME-}"'/Library/*' \
  ! -path '*/.git/*' \
  ! -path '*/Test*' \
  ! -path '*/test*' \
  ! -path '*/.well-known/*' \
  ! -name "$(printf -- 'Icon\015\012')" \
  ! -name '*LOCK' \
  ! -name '*empty*' \
  ! -name '*ignore' \
  ! -name '*journal' \
  ! -name '*lock' \
  ! -name '*lockfile' \
  ! -name '.dirstamp' \
  ! -name '.git' \
  ! -name '.gitkeep' \
  ! -name '.gitmodules' \
  ! -name '.hushlogin' \
  ! -name '.keep' \
  ! -name '.sudo_as_admin_successful' \
  ! -name '.watchmanconfig' \
  ! -name '.well-known' \
  ! -name '__init__.py' \
  ! -name 'favicon.*' \
  -delete

# if the shell can be changed and
# if zsh is available, then replace bash, ash, and sh with zsh in `/etc/passwd`
test -w '/etc/passwd' &&
  command -v -- zsh >/dev/null 2>&1 &&
  command grep -E -e '/bin/b?a?sh' '/etc/passwd' 2>&1 &&
  command cp -- '/etc/passwd' '/etc/passwd-'"${now-}" &&
  command sed -e 's|/bin/b\{0,1\}a\{0,1\}sh$|'"$(command -v -- zsh)"'|' '/etc/passwd-'"${now-}" >'/etc/passwd'

# done
{ set +euvx; } 2>/dev/null
printf -- 'installation complete\n' 2>/dev/null
command sleep 1
printf -- 'exiting to apply updates...\n' 2>/dev/null

# restore `$PS4`
PS4="${ps4_temporary:-+ }"
unset -v -- ps4_temporary

{
  printf -- '\n'
  printf -- 'done!\n'
} 2>/dev/null

exit
