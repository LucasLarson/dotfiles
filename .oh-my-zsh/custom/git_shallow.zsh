#!/usr/bin/env sh
#
#
#
# Shallow .gitmodules submodule installations
# Mauricio Scheffer https://stackoverflow.com/a/2169914

git_shallow() {
  git submodule init
  for i in $(git submodule | sed -e 's/.* //'); do
    submodule_path=$(git config --file .gitmodules --get submodule."$i".path)
    submodule_url=$(git config --file .gitmodules --get submodule."$i".url)
    git clone --depth 1 --shallow-submodules "$submodule_url" "$submodule_path"
  done
  git submodule update
}
