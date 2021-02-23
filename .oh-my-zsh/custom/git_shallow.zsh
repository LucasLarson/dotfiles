#!/usr/bin/env sh
#
#
#
# Shallow .gitmodules submodule installations
# Mauricio Scheffer https://stackoverflow.com/a/2169914

git_shallow() {
  git submodule init
  for i in $(git submodule | sed -e 's/.* //'); do
    spath=$(git config --file .gitmodules --get submodule."$i".path)
    surl=$(git config --file .gitmodules --get submodule."$i".url)
    git clone --depth 1 "$surl" "$spath"
  done
  git submodule update
}
