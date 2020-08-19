update=-1 &&

clear &&

clear &&

printf '                 .___       __\n __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n a Lucas Larson production\n\n' &&

sleep 1.0 &&

printf '\n\xf0\x9f\x93\xa1 verifying network connectivity...\n' &&

sleep 0.5 &&

(ping -q -i1 -c1 one.one.one.one &> /dev/null && ping -q -i1 -c1 8.8.8.8 &> /dev/null) || (printf 'No internet connection was detected.\nAborting update.\n' && return $update) &&

for ((i = 0; i < 1024; i++)); do if (((i / 3) % 2 == 0)); then printf .; else printf \\b; fi; done &&

printf \\n &&

ping -q -w1 -c1 one.one.one.one &> /dev/null && ping -q -w1 -c1 8.8.8.8 &> /dev/null &&

apk update --progress --verbose && apk upgrade --progress --verbose && apk fix --progress --verbose && apk verify --progress --verbose &&

pip3 install --upgrade pip &&

omz update &&

source ~/.zshrc &&

unset update &&

printf \\n\\n\\xe2\\x9c$update\\x85\ done\\x21\\n\\n &&

exec zsh
