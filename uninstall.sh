#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${PREFIX:-"$HOME/.local"}"
bindir="${BINDIR:-"$prefix/bin"}"

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

