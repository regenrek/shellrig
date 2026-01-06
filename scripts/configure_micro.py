#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


def die(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(1)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}
    except json.JSONDecodeError as e:
        die(f"invalid JSON in {path}: {e}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Configure micro editor settings safely.")
    parser.add_argument("--softwrap", choices=["true", "false"], default="true")
    parser.add_argument("--wordwrap", choices=["true", "false"], default=None)
    args = parser.parse_args()

    xdg_config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")).expanduser()
    micro_dir = xdg_config_home / "micro"
    micro_dir.mkdir(parents=True, exist_ok=True)

    settings_path = micro_dir / "settings.json"
    current = load_json(settings_path)
    if not isinstance(current, dict):
        die(f"expected JSON object in {settings_path}")

    desired: dict[str, object] = {"softwrap": args.softwrap == "true"}
    if args.wordwrap is not None:
        desired["wordwrap"] = args.wordwrap == "true"

    updated = dict(current)
    updated.update(desired)

    settings_path.write_text(json.dumps(updated, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    print(f"Configured micro: {settings_path}")


if __name__ == "__main__":
    main()

