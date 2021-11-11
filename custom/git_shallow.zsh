#!/usr/bin/env sh
#
# Shallow .gitmodules submodule installations
# Mauricio Scheffer https://stackoverflow.com/a/2169914

git_shallow() {
  command git submodule init
  for i in $(command git submodule | command sed -e 's/.* //'); do
    submodule_path=$(command git config --file .gitmodules --get submodule."${i}".path)
    submodule_url=$(command git config --file .gitmodules --get submodule."${i}".url)
    command git clone --depth 1 --shallow-submodules --sparse "${submodule_url}" "${submodule_path}"
  done
  command git submodule update
}
