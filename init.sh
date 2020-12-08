#!/usr/bin/env sh

# apk
if ! command -v apk >/dev/null 2>&1; then
  # https://github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version/89019508ddd504e6f08af30d8c8da2d3a8691b76#wiki-body
  wget --quiet --output-document - http://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz apk.static && ./apk.static add apk-tools && rm apk.static
fi

# configure repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n' >/etc/apk/repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n' >>/etc/apk/repositories

# update
apk update --verbose --progress
apk upgrade --verbose --progress

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Man_pages
apk add mandoc mandoc-doc man-pages less less-doc

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working#Shell_.40_commandline
apk add util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc

# make, cmake
apk add make make-doc cmake cmake-doc

# ssh
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
apk add openssh openssh-doc gnupg gnupg-doc

# git
apk add git git-doc

# time zone
apk add tzdata tzdata-doc
cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York\n' >/etc/timezone

# python, pip
printf 'installing Python...\n'
apk add curl curl-doc python2 python2-doc python3 python3-doc
if ! command -v pip >/dev/null 2>&1; then
  curl http://web.archive.org/web/20201031072740id_/bootstrap.pypa.io/get-pip.py -o get-pip.py
  printf 'installing pip...\n'
  python3 get-pip.py
fi

# zsh
printf 'installing Zsh...\n'
apk add zsh zsh-doc

# update, repair everything again before close
printf 'updating...\n'
apk update --verbose --progress
printf 'upgrading...\n'
apk upgrade --verbose --progress
printf 'repairing and resolving dependencies...\n'
apk fix --verbose --verbose --depends --progress
printf 'verifying installations...\n'
apk verify --verbose --verbose --progress
printf 'updating Python\xe2\x80\x99s package manager...\n'
command -v pip >/dev/null 2>&1 && python3 -m pip install --upgrade pip

# cleanup
printf '\n\ncleaning up temporary installation files...\n'
[ -e get-pip.py ] && rm get-pip.py
find -- . -empty -delete

# done
printf 'initialization complete\n'
printf 'restarting...\ndone!\n\n'
sleep 1
exec "${SHELL##*/}" -l || exit
