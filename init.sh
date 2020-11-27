# https://wiki.alpinelinux.org/w/index.php?oldid=17773&title=How_to_get_regular_stuff_working
apk add mandoc man-pages less-doc

export PAGER=less

apk add util-linux pciutils usbutils coreutils binutils findutils grep

# time zone
apk add tzdata
cp /usr/share/zoneinfo/America/New_York /etc/localtime
printf 'America/New_York' > /etc/timezone
apk del tzdata