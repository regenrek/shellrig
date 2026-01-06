#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${PREFIX:-"$HOME/.local"}"
bindir="${BINDIR:-"$prefix/bin"}"
xdg_config_home="${XDG_CONFIG_HOME:-"$HOME/.config"}"
zsh_config_dir="${ZSH_CONFIG_DIR:-"$xdg_config_home/zsh"}"

removed=0
for file in "$root_dir"/bin/*; do
  [[ -f "$file" && -x "$file" ]] || continue
  name="$(basename "$file")"
  link="$bindir/$name"
  [[ -L "$link" ]] || continue

  target="$(readlink "$link" || true)"
  [[ "$target" == "$file" ]] || continue

  rm -f "$link"
  removed=$((removed + 1))
done

printf 'Removed %s symlink(s) from %s\n' "$removed" "$bindir"

plugin_link="$zsh_config_dir/shellrig.zsh"
if [[ -L "$plugin_link" ]]; then
  target="$(readlink "$plugin_link" || true)"
  if [[ "$target" == "$root_dir/zsh/shellrig.zsh" ]]; then
    rm -f "$plugin_link"
    printf 'Removed zsh plugin symlink: %s\n' "$plugin_link"
  fi
fi
