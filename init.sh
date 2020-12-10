#!/usr/bin/env sh

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
(
  command -v mandoc >/dev/null 2>&1 && \
  command -v man-pages >/dev/null 2>&1
) || (
  printf '\ninstalling man pages...\n'
  apk add mandoc mandoc-doc man-pages less less-doc
)

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Shell_.40_commandline
apk add util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc

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
command -v tzdata >/dev/null 2>&1 || (
  printf '\ninstalling tzdata...\n'
  apk add tzdata tzdata-doc
)
cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York\n' >/etc/timezone

# python, pip
command -v python >/dev/null 2>&1 || (
  printf '\ninstalling Python...\n'
  apk add curl curl-doc python2 python2-doc python3 python3-doc
)
command -v pip >/dev/null 2>&1 || (
  printf '\ninstalling pip...\n'
  curl http://web.archive.org/web/20201031072740id_/bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
)

# zsh
command -v zsh >/dev/null 2>&1 || (
  printf '\ninstalling Zsh...\n'
  apk add zsh zsh-doc
)

# update, repair everything again before close
printf 'updating...\n'
apk update --verbose --progress
printf 'upgrading...\n'
apk upgrade --verbose --progress
printf 'repairing and resolving dependencies...\n'
apk fix --verbose --verbose --depends --progress
printf 'verifying installations...\n'
apk verify --verbose --verbose --progress
command -v pip >/dev/null 2>&1 && (
  printf '\nupdating Python\xe2\x80\x99s package manager...\n'
  python3 -m pip install --upgrade pip
)

# mackup
command -v mackup >/dev/null 2>&1 || (
  printf '\ninstalling mackup...\n'
  pip install --upgrade mackup
)

# cleanup
printf '\n\ncleaning up temporary installation files...\n'
[ -e get-pip.py ] && rm get-pip.py
find -- . -empty -delete

# done
printf 'initialization complete\n'
printf 'restarting...\ndone!\n\n'
sleep 1
exec "${SHELL##*/}" -l || exit
