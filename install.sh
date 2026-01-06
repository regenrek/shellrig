#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${PREFIX:-"$HOME/.local"}"
bindir="${BINDIR:-"$prefix/bin"}"

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

