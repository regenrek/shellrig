#!/usr/bin/env zsh
setopt err_return no_unset pipe_fail

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

alias gcur='git branch --show-current'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first --color=auto'
  alias ll='eza -lah --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza -T -L 2 --icons --group-directories-first'
fi

if command -v tmux >/dev/null 2>&1; then
  alias tks='tmux kill-session -t "$(tmux display-message -p "#S")"'
fi
