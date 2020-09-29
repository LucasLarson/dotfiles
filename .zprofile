#!/usr/bin/env zsh

# Rust
# add Rust’s Cargo `bin` to the $PATH if the directory exists
[[ -d $HOME/.cargo/bin ]] && export PATH="$HOME/.cargo/bin:$PATH"
