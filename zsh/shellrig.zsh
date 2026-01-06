#!/usr/bin/env zsh
setopt err_return no_unset pipe_fail

if [[ -n "${__SHELLRIG_LOADED:-}" ]]; then
  return 0
fi
__SHELLRIG_LOADED=1

_shellrig_dir="${0:A:h}"

source "${_shellrig_dir}/aliases.zsh"
source "${_shellrig_dir}/project.zsh"
source "${_shellrig_dir}/co.zsh"
source "${_shellrig_dir}/git-tools.zsh"
