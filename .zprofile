
export PATH="$HOME/.cargo/bin:$PATH"


# libffi for rbenv searches for “C++ preprocessor "/lib/cpp"” which
# “fails sanity check”. Added 2020-02-28 and should be able to be removed when
# rbenv understands that (I’m guessing) it’s not yet ready for 10.15.4 Beta
# via https://apple.stackexchange.com/a/99157
# alias '/lib/cpp'='/usr/bin/cpp'
# alias '/lib/cpp'='/usr/local/bin/cpp'
alias '/lib/cpp'='/usr/local/bin/gcc'
# alias '/lib/cpp'='/usr/bin/gcc'

# you’ll probably also need to clean up the mess you made with this cargo-cult
# Gist https://gist.github.com/Dreyer/0a0976f5606c0c963ab9a622f03ee26d
