#!/usr/bin/env sh

# apk
# https://github.com/ish-app/ish/wiki/Installing-apk-on-the-App-Store-Version/89019508ddd504e6f08af30d8c8da2d3a8691b76#wiki-body
wget -qO- http://web.archive.org/web/20201127185919id_/dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz sbin/apk.static && ./sbin/apk.static add apk-tools && rm sbin/apk.static
# For latest apk-tools, go to http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86/

# configure repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n' >/etc/apk/repositories
printf 'http://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n' >>/etc/apk/repositories

# update
apk update --verbose --progress
apk upgrade --verbose --progress

apk add curl curl-doc python2 python2-doc python3 python3-doc

# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working
apk add mandoc mandoc-doc man-pages less less-doc

apk add util-linux util-linux-doc pciutils pciutils-doc usbutils usbutils-doc coreutils coreutils-doc binutils binutils-doc findutils findutils-doc grep grep-doc

# SSH
# https://wiki.alpinelinux.org/w/index.php?oldid=13842&title=Setting_up_a_ssh-server#OpenSSH
# https://wiki.alpinelinux.org/w/index.php?oldid=17295&title=Setting_up_a_laptop#Creating_GPG_keys
apk add openssh openssh-doc gnupg gnupg-doc

# time zone
apk add tzdata tzdata-doc
cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York\n' >/etc/timezone
