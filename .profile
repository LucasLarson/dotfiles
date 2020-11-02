#!/usr/bin/env zsh

# Rust
# if Rust’s Cargo `bin` is a directory, then add it to the $PATH
if [[ -d $HOME/.cargo/bin ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
