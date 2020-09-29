#!/usr/bin/env zsh

# Rust
# if Rust’s Cargo `bin` is a directory, then add it to the $PATH
[[ -d $HOME/.cargo/bin ]] && export PATH="$HOME/.cargo/bin:$PATH"
