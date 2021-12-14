#!/usr/bin/env bash


export PATH="$HOME/.fastlane/bin:$PATH"

# Tidy for Mac OS X by balthisar.com is adding the new path for Tidy.
export PATH=/usr/local/bin:$PATH

# Tidy for Mac OS X by balthisar.com is adding the new path for Tidy.
export PATH=/usr/local/bin:$PATH

### Bashhub.com Installation.
### This Should be at the EOF. https://bashhub.com/docs
if [ -f ~/.bashhub/bashhub.sh ]; then
    source ~/.bashhub/bashhub.sh
fi
