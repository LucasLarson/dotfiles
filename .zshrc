#!/usr/bin/env zsh

## Powerlevel10k
# instant prompt
. "${XDG_CACHE_HOME-}"'/p10k-instant-prompt-'"${USER-}"'.zsh'

## PATH
# https://opengroup.org/onlinepubs/9699919799/utilities/command.html
# prepend without extra colon `:`
# https://unix.stackexchange.com/a/415028
PATH="$(command -p -- getconf PATH)${PATH:+:${PATH-}}"
# https://github.com/archlinux/svntogit-packages/commit/a10f20b/filesystem/trunk/profile
test -d '/usr/local/sbin' &&
  PATH='/usr/local/sbin'"${PATH:+:${PATH-}}"
# /usr/local/bin first
# https://stackoverflow.com/a/34984922
test -d '/usr/local/bin' &&
  PATH='/usr/local/bin'"${PATH:+:${PATH-}}"

# set PATH so it includes applicable private `bin`s
test -d "${HOME-}"'/bin' &&
  PATH="${HOME-}"'/bin'"${PATH:+:${PATH-}}"
test -d "${HOME-}"'/.local/bin' &&
  PATH="${HOME-}"'/.local/bin'"${PATH:+:${PATH-}}"

## Plugin manager
test -d "${HOME-}"'/.oh-my-zsh' &&
  export ZSH="${HOME-}"'/.oh-my-zsh'

## Theme
if test -r "${ZSH_CUSTOM-}"'/themes/powerlevel10k/powerlevel10k.zsh-theme' &&
  {
    test "$(command uname)" = 'Darwin' ||
      test "$((COLUMNS * LINES))" -gt "$((80 * 24))"
  }; then
  . "${ZSH_CUSTOM-}"'/themes/powerlevel10k/powerlevel10k.zsh-theme'
  export ZSH_THEME='powerlevel10k/powerlevel10k'
fi

# set maximum number of lines in history file
# https://unix.stackexchange.com/a/111777
SAVEHIST="$(printf '2 ^ 32 - 1\n' | command bc)" # 4,294,967,295 in history file
HISTSIZE="$((SAVEHIST / 2))"                     # 2,147,478,647 in session
export SAVEHIST HISTSIZE

## zsh compdump
# https://github.com/ohmyzsh/ohmyzsh/commit/d2fe03d
export ZSH_COMPDUMP="${HOME-}"'/.zcompdump'

## Plugins
# plugins at the beginning of the array are
# overridden by plugins at its end
plugins+=(
  gunstage
  samefile
  git-default-branch
  git-open
  zsh-abbr
  zsh-diff-so-fancy
)

# plugin: zsh_codex
test -r "${XDG_CONFIG_HOME-}"'/openaiapirc' || {
  printf '[openai]\n'
  printf 'organization_id = %s\n' "${OPENAI_ORGANIZATION_ID-}"
  printf 'secret_key = %s\n' "${OPENAI_SECRET_KEY-}"
} >|"${XDG_CONFIG_HOME-}"'/openaiapirc' &&
  bindkey '^X' create_completion &&
  plugins+=(
    zsh_codex
  )

# plugin: fast-syntax-highlighting
# performs best when loaded late, but before zsh-history-substring-search
plugins+=(
  fast-syntax-highlighting
)

# plugin: zsh-history-substring-search
plugins+=(
  # load after fast-syntax-highlighting
  # https://github.com/zsh-users/zsh-history-substring-search/blob/02a1971540/history-substring-search.zsh
  zsh-history-substring-search
) && {
  # https://github.com/zsh-users/zsh-history-substring-search/commit/9c51863eb2
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}

## Options
# completion
set -o always_to_end
set -o complete_in_word
set +o flow_control

# go to directory without `cd`
set -o autocd

# history
set -o extended_history
set -o hist_ignore_dups
set -o hist_ignore_space
# bash-compatible
set -o histverify

## shell navigation without the mouse
bindkey '^?' backward-delete-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete

## Oh My Zsh
. "${ZSH-}"'/oh-my-zsh.sh'

for file in "${ZSH_CUSTOM-}"/plugins/**/*.plugin.*sh; do
  . "${file-}" 2>/dev/null &&
    FPATH="${FPATH:+${FPATH-}:}$(command dirname -- "${file-}")"
done
for file in "${ZSH_CUSTOM-}"/*sh; do
  . "${file-}"
done

## MANPATH
# Linux
test -d '/usr/local/man' &&
  MANPATH='/usr/local/man'"${MANPATH:+:${MANPATH-}}"
# macOS
test -d '/usr/share/man' &&
  MANPATH='/usr/share/man'"${MANPATH:+:${MANPATH-}}"
# if `man -w` does not fail, then add it to `$MANPATH`
command man -w >/dev/null 2>&1 &&
  MANPATH="${MANPATH:+${MANPATH-}:}$(command man -w)"

## EDITOR
# access favorite with `e`
# Set preferred editor if it is available
if command -v -- nvim >/dev/null 2>&1; then
  EDITOR="$(command -v -- nvim)"
elif command -v -- vim >/dev/null 2>&1; then
  EDITOR="$(command -v -- vim)"
elif command -v -- vi >/dev/null 2>&1; then
  EDITOR="$(command -v -- vi)"
fi
if test -n "${EDITOR-}"; then
  export EDITOR
  alias e='command "${EDITOR-}"'
  export VISUAL="${VISUAL:-${EDITOR-}}"
fi

## GPG
# sign with macOS-compatible Linux
# https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key#telling-git-about-your-gpg-key
# https://reddit.com/comments/dk53ow#t1_f50146x
# https://github.com/romkatv/powerlevel10k/commit/faddef4
export GPG_TTY="${TTY-}"

## Homebrew
# https://github.com/Homebrew/brew/blob/a5b6c5f/Library/Homebrew/diagnostic.rb#L432-L435
if command -v -- brew >/dev/null 2>&1; then

  # https://github.com/driesvints/dotfiles/blob/388baf1/path.zsh#L17
  HOMEBREW_PREFIX="$(command brew --prefix)"
  test -d "${HOMEBREW_PREFIX-}"'/sbin' &&
    PATH="${HOMEBREW_PREFIX-}"'/sbin'"${PATH:+:${PATH-}}"

  # GNU bc calculator
  test -d "${HOMEBREW_PREFIX-}"'/opt/bc/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/bc/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/bc/share/man' &&
    # Homebrew `MANPATH`
    # https://github.com/ferrarimarco/dotfiles/blob/eb176e4/.path#L14-L20
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/bc/share/man'"${MANPATH:+:${MANPATH-}}"

  # curl
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/curl/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/curl/share/man'"${MANPATH:+:${MANPATH-}}"

  # GNU coreutils
  # for `date`, `cat`, `ln`
  # https://apple.stackexchange.com/a/135749
  test -d "${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # file
  test -d "${HOMEBREW_PREFIX-}"'/opt/file/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/file/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/file/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/file/share/man'"${MANPATH:+:${MANPATH-}}"

  # GNU findutils
  # for `find`, `xargs`, `locate`
  test -d "${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # grep
  # use latest via Homebrew but without the `g` prefix
  # https://github.com/Homebrew/homebrew-core/blob/ba7a70f/Formula/grep.rb#L43-L46
  test -d "${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # libarchive
  test -d "${HOMEBREW_PREFIX-}"'/opt/libarchive/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/libarchive/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/libarchive/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/libarchive/share/man'"${MANPATH:+:${MANPATH-}}"

  # make
  # use latest via Homebrew but without the `g` prefix
  # https://github.com/Homebrew/homebrew-core/blob/9591758/Formula/make.rb#L37-L41
  test -d "${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  ## Node
  # version 16 at head of `PATH` to support GitHub Copilot
  # https://github.com/github/copilot.vim/commit/f6cdb5caae
  test -d "${HOMEBREW_PREFIX-}"'/opt/node@16/bin' &&
    PATH='/usr/local/opt/node@16/bin'"${PATH:+:${PATH-}}" &&
    MANPATH='/usr/local/opt/node@16/share'"${MANPATH:+:${MANPATH-}}" &&
    export LDFLAGS="${LDFLAGS:+${LDFLAGS-} }"'-L'"${HOMEBREW_PREFIX-}"'/opt/node@16/lib' &&
    export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS-} }"'-I'"${HOMEBREW_PREFIX-}"'/opt/node@16/include'

  # openssl
  test -d "${HOMEBREW_PREFIX-}"'/opt/openssl/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/openssl/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/openssl/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/openssl/share/man'"${MANPATH:+:${MANPATH-}}"
  # `$LDFLAGS`, `$CPPFLAGS` are space-delimited
  # https://thelinuxcluster.com/2018/11/13/using-multiple-ldflags-and-cppflags
  # skip adding initial and terminal spaces
  # https://unix.stackexchange.com/a/162893
  export LDFLAGS="${LDFLAGS:+${LDFLAGS-} }"'-L'"${HOMEBREW_PREFIX-}"'/opt/openssl/lib'
  export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS-} }"'-I'"${HOMEBREW_PREFIX-}"'/opt/openssl/include'
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+${PKG_CONFIG_PATH-}:}${HOMEBREW_PREFIX-}"'/opt/openssl/lib/pkgconfig'

  # sed
  # https://github.com/Homebrew/homebrew-core/blob/8ec6f0e/Formula/gnu-sed.rb#L35-L39
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # texinfo for `info`
  # “more detailed than . . . manpage (as is true for most GNU utilities)”
  # https://stackoverflow.com/a/1489405
  test -d "${HOMEBREW_PREFIX-}"'/opt/texinfo/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/texinfo/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/texinfo/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/texinfo/share/man'"${MANPATH:+:${MANPATH-}}"
fi

## Rust
# if its `bin` is a directory, then add it to `PATH`
test -d "${HOME-}"'/.cargo/bin' &&
  PATH="${HOME-}"'/.cargo/bin'"${PATH:+:${PATH-}}"

## Bashhub
test -r "${HOME-}"'/.bashhub/bashhub.'"${SHELL##*[-./]}" && {
  . "${HOME-}"'/.bashhub/bashhub.'"${SHELL##*[-./]}"
}

## npm
# without sudo
# https://github.com/sindresorhus/guides/blob/285270f/npm-global-without-sudo.md#3-ensure-npm-will-find-installed-binaries-and-man-pages
NPM_PACKAGES="${HOME-}"'/.npm-packages'
test -d "${NPM_PACKAGES-}"'/bin' &&
  PATH="${PATH:+${PATH-}:}${NPM_PACKAGES-}"'/bin'
test -d "${NPM_PACKAGES-}"'/share/man' &&
  MANPATH="${MANPATH:+${MANPATH-}:}${NPM_PACKAGES-}"'/share/man'

# include hidden files in tab completion
# https://unix.stackexchange.com/a/366137
# `setopt globdots` alias for bash-compatibility
set -o dotglob
# but hide `./` and `../`
# https://unix.stackexchange.com/q/308315#comment893697_308322
zstyle ':completion:*' special-dirs false
# https://github.com/TimButters/dotfiles/blob/3e03c81/zshrc#L46-L50
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %F"{green}"%d%f

## plugin: zsh-completions
# https://github.com/Homebrew/homebrew-core/blob/7cf42e0/Formula/zsh-completions.rb#L18-L23
# https://github.com/zsh-users/zsh-completions/tree/f68950a#oh-my-zsh
test -d "${ZSH_CUSTOM-}"'/plugins/zsh-completions/src' &&
  FPATH="${FPATH:+${FPATH-}:}${ZSH_CUSTOM-}"'/plugins/zsh-completions/src'

autoload -U compinit &&
  compinit

# share all commands from everywhere
# https://github.com/mcornella/dotfiles/blob/047eaa1/zshrc#L104-L105
set -o share_history

# permit inline comments after hash signs `#`
# https://stackoverflow.com/a/11873793
set -o interactive_comments

## pyenv
test -d "${HOME-}"'/.pyenv/shims' &&
  PATH="${HOME-}"'/.pyenv/shims'"${PATH:+:${PATH-}}"
# https://gist.github.com/4a4c4986ccdcaf47b91e8227f9868ded#prezto
# https://github.com/caarlos0/carlosbecker.com/commit/c5f04d6
pyenv() {
  eval "$(command pyenv init - --no-rehash "${SHELL##*[-./]}")"
  pyenv "$@"
}

## C, C++
# headers
# https://apple.stackexchange.com/a/372600
if command -v -- xcrun >/dev/null 2>&1 &&
  test -n "$(command xcrun --show-sdk-path)"; then
  # `CPATH` is delimited like `PATH` as are
  # `C_INCLUDE_PATH`, `OBJC_INCLUDE_PATH`,
  # `CPLUS_INCLUDE_PATH`, and `OBJCPLUS_INCLUDE_PATH`
  # https://github.com/llvm/llvm-project/commit/16af476
  CPATH="$(command xcrun --show-sdk-path)"'/usr/include'"${CPATH:+:${CPATH-}}"
  export CPATH
fi

## cpplint
# `$LIBRARY_PATH` || ld: library not found for -lSystem
# https://stackoverflow.com/a/65428700
if test -d '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'; then
  LIBRARY_PATH='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'"${LIBRARY_PATH:+:${LIBRARY_PATH-}}"
  export LIBRARY_PATH
fi

## Go
test -n "${GOPATH-}" &&
  test -d "${GOPATH-}"'/bin' &&
  PATH="${GOPATH-}"'/bin'"${PATH:+:${PATH-}}"

## pip
# location of Python packages on Linux
test -d "${HOME-}"'/.local/bin' &&
  PATH="${HOME-}"'/.local/bin'"${PATH:+:${PATH-}}"

## rbenv
# https://hackernoon.com/the-only-sane-way-to-setup-fastlane-on-a-mac-4a14cb8549c8#6a04
# https://gist.github.com/4a4c4986ccdcaf47b91e8227f9868ded#prezto
# https://github.com/caarlos0/carlosbecker.com/commit/c5f04d6
test -d "${HOME-}"'/.rbenv/shims' &&
  PATH="${HOME-}"'/.rbenv/shims'"${PATH:+:${PATH-}}"
rbenv() {
  eval "$(command rbenv init - --no-rehash "${SHELL##*[-./]}")"
  rbenv "$@"
}

## PATHs
# prevent duplicate entries
# https://github.com/mcornella/dotfiles/blob/e62b0d4/zshenv#L63-L67
# https://github.com/zsh-users/zsh/blob/a9061cc/StartupFiles/zshrc#L56-L57
# https://github.com/zsh-users/zsh/commit/db3f2d2
test -n "${ZSH-}" &&
  export -U \
    PATH path \
    CDPATH cdpath \
    FPATH fpath \
    MANPATH manpath

## Powerlevel10k
# prompt
# if the theme is powerlevel10k,
test "${ZSH_THEME-}" = 'powerlevel10k/powerlevel10k' &&
  # then source `~/.p10k.zsh`
  . "${HOME-}"'/.p10k.zsh'
