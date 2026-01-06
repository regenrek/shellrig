#!/usr/bin/env zsh

gdelta() {
  emulate -L zsh -o err_return -o pipe_fail

  local mode="worktree"
  local -a extra_args=()

  case "${1:-}" in
    staged|--staged|-s)
      mode="staged"
      shift
      ;;
    --help|-h)
      cat >&2 <<'EOF'
usage:
  gdelta                 # local working tree diff
  gdelta staged          # staged diff
  gdelta -- <git diff args>
EOF
      return 0
      ;;
  esac

  if [[ "${1:-}" == "--" ]]; then
    shift
    extra_args=("$@")
  else
    extra_args=("$@")
  fi

  if (( ! $+commands[delta] )); then
    echo "gdelta: delta not found in PATH" >&2
    return 127
  fi

  case "$mode" in
    staged)
      git diff --cached --color=always "${extra_args[@]}" | delta
      ;;
    *)
      git diff --color=always "${extra_args[@]}" | delta
      ;;
  esac
}

gpick() {
  emulate -L zsh -o err_return -o pipe_fail

  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "usage: gpick <search terms>" >&2
    return 0
  fi
  if [[ $# -eq 0 ]]; then
    echo "usage: gpick <search terms>" >&2
    return 2
  fi

  local query="$*"
  if [[ "$query" == *$'\n'* || "$query" == *$'\r'* ]]; then
    echo "gpick: query must be single-line" >&2
    return 2
  fi

  if (( ! $+commands[gh] )); then
    echo "gpick: gh not found in PATH" >&2
    return 127
  fi
  if (( ! $+commands[jq] )); then
    echo "gpick: jq not found in PATH" >&2
    return 127
  fi
  if (( ! $+commands[fzf] )); then
    echo "gpick: fzf not found in PATH" >&2
    return 127
  fi

  local selected
  selected="$(
    gh search repos "$query" --limit 50 --json fullName,description,stargazersCount,url \
      | jq -r '.[] | [.fullName, (.stargazersCount|tostring), (.description // ""), .url] | @tsv' \
      | fzf --with-nth=1,2,3 --delimiter=$'\t' --prompt 'repo> ' \
          --preview 'printf "%s\n%s\n" {1} {4}' --preview-window 'down,4,wrap'
  )" || return 1

  [[ -z "$selected" ]] && return 1

  print -r -- "$selected" | awk -F $'\t' '{print $1}'
}

_shellrig__normalize_repo_to_clone_url() {
  emulate -L zsh -o err_return -o pipe_fail

  local raw="$1"
  local host="github.com"
  local path=""

  if [[ "$raw" == git@*:* ]]; then
    print -r -- "$raw"
    return 0
  fi

  if [[ "$raw" == https://*/* || "$raw" == http://*/* || "$raw" == git://*/* ]]; then
    host="${raw#*://}"
    host="${host%%/*}"
    path="${raw#*://$host/}"
    path="${path%.git}"
    print -r -- "git@${host}:${path}.git"
    return 0
  fi

  if [[ "$raw" == ssh://git@*/* ]]; then
    host="${raw#ssh://git@}"
    host="${host%%/*}"
    path="${raw#ssh://git@$host/}"
    path="${path%.git}"
    print -r -- "git@${host}:${path}.git"
    return 0
  fi

  if [[ "$raw" == */* ]]; then
    path="${raw%.git}"
    print -r -- "git@${host}:${path}.git"
    return 0
  fi

  return 1
}

_shellrig__normalize_repo_to_owner_repo() {
  emulate -L zsh -o err_return -o pipe_fail

  local raw="$1"
  local host=""
  local path=""

  if [[ "$raw" == git@*:* ]]; then
    path="${raw#*:}"
    print -r -- "${path%.git}"
    return 0
  fi

  if [[ "$raw" == https://*/* || "$raw" == http://*/* || "$raw" == git://*/* ]]; then
    host="${raw#*://}"
    host="${host%%/*}"
    path="${raw#*://$host/}"
    print -r -- "${path%.git}"
    return 0
  fi

  if [[ "$raw" == ssh://git@*/* ]]; then
    host="${raw#ssh://git@}"
    host="${host%%/*}"
    path="${raw#ssh://git@$host/}"
    print -r -- "${path%.git}"
    return 0
  fi

  if [[ "$raw" == */* ]]; then
    print -r -- "${raw%.git}"
    return 0
  fi

  return 1
}

gclone() {
  emulate -L zsh -o err_return -o pipe_fail

  local mode="clone" # clone|print|expand
  case "${1:-}" in
    --help|-h)
      cat >&2 <<'EOF'
usage:
  gclone [--p|--ex] <search terms | owner/repo | git@... | ssh://... | https://...>

flags:
  --p           print owner/repo only (no clone)
  --ex          print SSH clone URL only (no clone)
EOF
      return 0
      ;;
    --p|-p)
      mode="print"
      shift
      ;;
    --ex|-e)
      mode="expand"
      shift
      ;;
  esac

  if [[ $# -eq 0 ]]; then
    echo "usage: gclone [--p|--ex] <search terms | git@... | ssh://... | https://...>" >&2
    return 2
  fi

  local query="$*"
  if [[ "$query" == *$'\n'* || "$query" == *$'\r'* ]]; then
    echo "gclone: query must be single-line" >&2
    return 2
  fi

  local repo_url=""
  if [[ "$query" == git@*:* || "$query" == ssh://* || "$query" == https://* || "$query" == http://* || "$query" == git://* ]]; then
    repo_url="$query"
  elif [[ "$query" == */* && "$query" != *" "* ]]; then
    repo_url="$query"
  else
    repo_url="$(gpick "$query")" || return 1
  fi

  if [[ -z "$repo_url" ]]; then
    echo "gclone: no repo selected" >&2
    return 1
  fi

  if [[ "$mode" == "print" ]]; then
    _shellrig__normalize_repo_to_owner_repo "$repo_url" || {
      echo "gclone: invalid repo url" >&2
      return 2
    }
    return 0
  fi

  local clone_url
  clone_url="$(_shellrig__normalize_repo_to_clone_url "$repo_url")" || {
    echo "gclone: invalid repo url" >&2
    return 2
  }

  if [[ "$mode" == "expand" ]]; then
    print -r -- "$clone_url"
    return 0
  fi

  local dest_base="${SHELLRIG_PROJECTS_DIR:-$HOME/projects}"
  mkdir -p "$dest_base"

  git -C "$dest_base" clone "$clone_url"
}
