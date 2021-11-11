#!/usr/bin/env sh
#
# Shallow .gitmodules submodule installations
# Mauricio Scheffer https://stackoverflow.com/a/2169914

git_shallow() {
  command git submodule init
  for submodule in $(command git submodule | command sed -e 's/.* //'); do
    submodule_path="$(command git config --file .gitmodules --get submodule."${submodule}".path)"
    submodule_url="$(command git config --file .gitmodules --get submodule."${submodule}".url)"
    command git clone --depth=1 --shallow-submodules "${submodule_url}" "${submodule_path}"
  done
  command git submodule update
}
