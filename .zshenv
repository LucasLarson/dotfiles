# .zshenv


# $EDITOR: access favorite with `edit`
# Set preferred editor if it is available
# https://stackoverflow.com/a/14755066
# https://github.com/wililupy/snapd/commit/0573e7b
if command -v nvim > /dev/null 2>&1; then
  EDITOR="nvim"
elif command -v vim > /dev/null 2>&1; then
  EDITOR="vim"
elif command -v vi > /dev/null 2>&1; then
  EDITOR="vi"
else
  EDITOR="nano"
fi
export EDITOR
# https://github.com/koalaman/shellcheck/wiki/SC2139/db553bf16fcb86b2cdc77b835e75b9121eacc429#this-expands-when-defined-not-when-used-consider-escaping
alias editor='$EDITOR'
alias edit="editor"
