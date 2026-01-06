#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${PREFIX:-"$HOME/.local"}"
bindir="${BINDIR:-"$prefix/bin"}"
xdg_config_home="${XDG_CONFIG_HOME:-"$HOME/.config"}"
zsh_config_dir="${ZSH_CONFIG_DIR:-"$xdg_config_home/zsh"}"

configure_micro=0
configure_zsh=1
force=0
for arg in "$@"; do
  case "$arg" in
    --micro)
      configure_micro=1
      ;;
    --no-zsh)
      configure_zsh=0
      ;;
    --force)
      force=1
      ;;
    --help|-h)
      cat <<EOF
usage:
  ./install.sh [--micro] [--no-zsh] [--force]

flags:
  --micro    configure micro editor (enable softwrap)
  --no-zsh   skip zsh plugin symlink
  --force    overwrite conflicting files/symlinks
EOF
      exit 0
      ;;
  esac
done
if [[ "${SHELLRIG_CONFIGURE_MICRO:-0}" == "1" ]]; then
  configure_micro=1
fi
if [[ "${SHELLRIG_NO_ZSH:-0}" == "1" ]]; then
  configure_zsh=0
fi
if [[ "${SHELLRIG_FORCE:-0}" == "1" ]]; then
  force=1
fi

link_or_die() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" ]]; then
      local target=""
      target="$(readlink "$dst" 2>/dev/null || true)"
      if [[ "$target" == "$src" ]]; then
        return 0
      fi
    fi

    if (( ! force )); then
      echo "error: $label already exists: $dst" >&2
      echo "hint: re-run with --force to overwrite" >&2
      exit 1
    fi
  fi

  ln -snf "$src" "$dst"
}

mkdir -p "$bindir"

installed=0
for file in "$root_dir"/bin/*; do
  [[ -f "$file" && -x "$file" ]] || continue
  name="$(basename "$file")"
  link_or_die "$file" "$bindir/$name" "bin link"
  installed=$((installed + 1))
done

printf 'Installed %s script(s) to %s\n' "$installed" "$bindir"
printf 'Ensure PATH includes: %s\n' "$bindir"

if (( configure_zsh )); then
  mkdir -p "$zsh_config_dir"
  link_or_die "$root_dir/zsh/shellrig.zsh" "$zsh_config_dir/shellrig.zsh" "zsh plugin link"
  printf 'Linked zsh plugin: %s -> %s\n' "$zsh_config_dir/shellrig.zsh" "$root_dir/zsh/shellrig.zsh"
else
  printf 'Skipped zsh plugin symlink (--no-zsh)\n'
fi

if (( configure_micro )); then
  if command -v python3 >/dev/null 2>&1; then
    python3 -B "$root_dir/scripts/configure_micro.py" --softwrap true
  else
    echo "warning: python3 not found; skipping micro configuration" >&2
  fi
fi
