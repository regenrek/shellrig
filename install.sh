#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${PREFIX:-"$HOME/.local"}"
bindir="${BINDIR:-"$prefix/bin"}"
xdg_config_home="${XDG_CONFIG_HOME:-"$HOME/.config"}"
zsh_config_dir="${ZSH_CONFIG_DIR:-"$xdg_config_home/zsh"}"

mkdir -p "$bindir"

installed=0
for file in "$root_dir"/bin/*; do
  [[ -f "$file" && -x "$file" ]] || continue
  name="$(basename "$file")"
  ln -snf "$file" "$bindir/$name"
  installed=$((installed + 1))
done

printf 'Installed %s script(s) to %s\n' "$installed" "$bindir"
printf 'Ensure PATH includes: %s\n' "$bindir"

mkdir -p "$zsh_config_dir"
ln -snf "$root_dir/zsh/shellrig.zsh" "$zsh_config_dir/shellrig.zsh"
printf 'Linked zsh plugin: %s -> %s\n' "$zsh_config_dir/shellrig.zsh" "$root_dir/zsh/shellrig.zsh"
