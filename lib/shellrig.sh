#!/usr/bin/env bash
set -euo pipefail

sr_die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

sr_log() {
  printf '%s\n' "$*" >&2
}

sr_require_cmd() {
  command -v "$1" >/dev/null 2>&1 || sr_die "missing required command: $1"
}

