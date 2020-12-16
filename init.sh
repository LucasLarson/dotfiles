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
printf ' a Lucas Larson production\n\n'
sleep 1

# apk
command -v apk >/dev/null 2>&1 || (
  # https://github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version/89019508ddd504e6f08af30d8c8da2d3a8691b76#wiki-body
  wget --output-document - http://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz apk.static
  ./apk.static add apk-tools
)

# configure repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n' >/etc/apk/repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n' >>/etc/apk/repositories

# update
printf '\nupdating Alpine Linux repository indeces...\n'
apk update --verbose --progress
apk upgrade --verbose --progress

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Man_pages
# man-pages adds `man0`, `man2`, man4`, `man6` to `/usr/share/man/`
[ -d /usr/share/man/man0 ] && \
  [ -d /usr/share/man/man2 ] && \
  [ -d /usr/share/man/man4 ] && \
  [ -d /usr/share/man/man6 ] || (
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
apk add util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc wget wget-doc

# make, cmake
apk add make make-doc cmake cmake-doc

# ssh
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
apk add openssh openssh-doc gnupg gnupg-doc

# git
command -v git >/dev/null 2>&1 || (
  printf '\ninstalling Git...\n'
  apk add git git-doc
)

# time zone
printf '\nupdating time zone information...\n'
apk add --no-cache tzdata tzdata-doc
cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York\n' >/etc/timezone

# python
printf '\nchecking Python installation...\n'
command -v python >/dev/null 2>&1 || (
  printf '\ninstalling Python...\n'
  apk add curl curl-doc python2 python2-doc python3 python3-doc
)

# pip
command -v pip >/dev/null 2>&1 || (
  printf '\ninstalling pip...\n'
  curl http://web.archive.org/web/20201031072740id_/bootstrap.pypa.io/get-pip.py -o get-pip.py
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
command -v omz >/dev/null 2>&1 || (
  printf 'installing Oh My Zsh...\n'
  [ -d "${HOME}/.oh-my-zsh" ] && rm -rf "${HOME}/.oh-my-zsh"
  sh -c "$(wget http://web.archive.org/web/20201211072817id_/raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh --output-document -)" "" --unattended --keep-zshrc
)

# update, repair everything again before close
printf '\nupdating...\n'
apk update --verbose --progress
printf '\nupgrading...\n'
apk upgrade --verbose --progress
printf '\nrepairing and resolving dependencies...\n'
apk fix --verbose --verbose --depends --progress
printf '\nverifying installations...\n'
apk verify --verbose --verbose --progress
command -v pip >/dev/null 2>&1 && (
  printf '\nupdating Python\xe2\x80\x99s package manager...\n'
  python3 -m pip install --upgrade pip
)

# cleanup
printf '\n\ncleaning up temporary installation files...\n'
[ -e apk.static ] && rm apk.static
[ -e get-pip.py ] && rm get-pip.py
find -- . -empty -delete

# done
printf '\ninitialization complete\n'
printf '\nrestarting...\ndone!\n\n'
sleep 1
exec "${0##*[-/]}" -l || exit
