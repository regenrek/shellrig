#!/usr/bin/env zsh

_shellrig__co_pick_files() {
  emulate -L zsh -o err_return -o pipe_fail

  local query="$1"
  shift
  local include_git=0
  if [[ "${1:-}" == "--include-git" ]]; then
    include_git=1
    shift
  fi

  if (( ! $+commands[fd] )); then
    echo "co: fd not found in PATH" >&2
    return 127
  fi
  if (( ! $+commands[fzf] )); then
    echo "co: fzf not found in PATH" >&2
    return 127
  fi

  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

  local -a fd_args=(
    --type f
    --hidden
    --follow
  )

  if (( ! include_git )); then
    fd_args+=(--exclude .git)
  fi

  cd -- "$root" || return 1
  fd "${fd_args[@]}" -- \
    | fzf -m --query "$query" --prompt 'co> ' \
        --preview 'bat --style=numbers --color=always -- {} 2>/dev/null || sed -n \"1,200p\" {}' \
        --preview-window 'up,82%,border-bottom'
}

co() {
  emulate -L zsh -o err_return -o pipe_fail

  local all=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all)
        all=1
        shift
        ;;
      --help|-h)
        cat >&2 <<'EOF'
usage:
  co [query]         # open files (excludes .git)
  co -a [query]      # open any file (includes .git)
EOF
        return 0
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
  done

  local query="${*:-}"
  local -a files
  if (( all )); then
    files=("${(@f)$(_shellrig__co_pick_files "$query" --include-git)}") || return $?
  else
    files=("${(@f)$(_shellrig__co_pick_files "$query")}") || return $?
  fi

  (( ${#files[@]} == 0 )) && return 1

  "${EDITOR:-micro}" -- "${files[@]}"
}
