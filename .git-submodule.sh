#!/usr/local/bin/zsh
# Shallow .gitmodules submodule installations
# Mauricio Scheffer https://stackoverflow.com/a/2169914
# place in the top of a Git repository and invoke with
# $ sh .git-submodule.sh
git submodule init
for i in $(git submodule | sed -e 's/.* //'); do
    spath=$(git config -f .gitmodules --get submodule.$i.path)
    surl=$(git config -f .gitmodules --get submodule.$i.url)
    git clone --depth 1 $surl $spath
done
git submodule update
