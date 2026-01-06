#!/usr/bin/env zsh

_shellrig__project_select() {
  emulate -L zsh -o err_return -o pipe_fail

  local query="$1"
  local -a roots existing_roots matches

  if [[ -z "$query" ]]; then
    echo "project: missing query" >&2
    return 2
  fi
  if [[ "$query" == *$'\n'* || "$query" == *$'\r'* ]]; then
    echo "project: query must be single-line" >&2
    return 2
  fi

  if (( ! $+commands[fd] )); then
    echo "project: fd not found in PATH" >&2
    return 127
  fi

  if (( ${#SHELLRIG_PROJECT_ROOTS[@]} > 0 )); then
    roots=("${SHELLRIG_PROJECT_ROOTS[@]}")
  else
    roots=("$HOME/projects" "$HOME/projects/external-codebase")
  fi

  local r
  for r in "${roots[@]}"; do
    [[ -d "$r" ]] && existing_roots+=("$r")
  done
  if (( ${#existing_roots[@]} == 0 )); then
    echo "project: no search roots exist" >&2
    return 1
  fi

  typeset -A seen
  local found_path dir
  while IFS= read -r found_path; do
    dir="${found_path:h}"
    [[ -n "$dir" ]] && seen[$dir]=1
  done < <(fd --hidden --follow --type d --type f --glob ".git" "${existing_roots[@]}")

  if (( ${#seen[@]} == 0 )); then
    echo "project: no projects found under roots" >&2
    return 1
  fi

  local ql="${query:l}"
  for dir in "${(@k)seen}"; do
    if [[ "${dir:l}" == *"$ql"* ]]; then
      matches+=("$dir")
    fi
  done

  if (( ${#matches[@]} == 0 )); then
    echo "project: no match for '$query'" >&2
    return 1
  fi

  local selected=""
  if (( ${#matches[@]} == 1 )); then
    selected="${matches[1]}"
  else
    if (( ! $+commands[fzf] )); then
      printf "%s\n" "${(@o)matches}" >&2
      echo "project: multiple matches; install fzf or refine query" >&2
      return 1
    fi
    selected="$(printf "%s\n" "${(@o)matches}" | fzf --prompt="project> " --height=40% --reverse)"
    [[ -z "$selected" ]] && return 1
  fi

  print -r -- "$selected"
}

# `pr` (project root): find a project and `cd` into it.
pr() {
  emulate -L zsh -o err_return -o pipe_fail

  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "usage: pr <query>" >&2
    return 0
  fi
  if [[ $# -eq 0 ]]; then
    echo "usage: pr <query>" >&2
    return 2
  fi

  local target
  target="$(_shellrig__project_select "$*")" || return $?
  cd -- "$target" || return 1
}

# `cwd` prints the matching project root path.
cwd() {
  emulate -L zsh -o err_return -o pipe_fail

  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat >&2 <<'EOF'
usage:
  cwd <query>

Notes:
  - Customize roots via `SHELLRIG_PROJECT_ROOTS` (zsh array).
EOF
    return 0
  fi
  if [[ $# -eq 0 ]]; then
    echo "usage: cwd <query>" >&2
    return 2
  fi

  _shellrig__project_select "$*"
}
