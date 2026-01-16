# Install

## Quick Start

Clone anywhere you like (examples assume `~/projects/shellrig`):

```bash
git clone git@github.com:regenrek/shellrig.git ~/projects/shellrig
```

Add `shellrig/bin` to your PATH (choose your shell config file):

- zsh (`~/.zshrc`):
  ```bash
  export PATH="$HOME/projects/shellrig/bin:$PATH"
  ```
- bash (`~/.bashrc`):
  ```bash
  export PATH="$HOME/projects/shellrig/bin:$PATH"
  ```
- fish (`~/.config/fish/config.fish`):
  ```fish
  fish_add_path -g "$HOME/projects/shellrig/bin"
  ```

Zsh functions/aliases (zsh only; add to `~/.zshrc`):

```bash
source "$HOME/projects/shellrig/zsh/shellrig.zsh"
```

## Advanced (install script — experienced users only)

`install.sh` creates symlinks in your home directory. Use only if you're comfortable with that, and prefer manual install if you only want a subset of commands.

What it touches:

- `~/.local/bin/*` symlinks to `shellrig/bin/*`
- `~/.config/zsh/shellrig.zsh` symlink to `shellrig/zsh/shellrig.zsh` (unless `--no-zsh`)
- `~/.config/micro/settings.json` (only with `--micro`)

Safety:

- Refuses to overwrite existing files unless `--force`

```bash
./install.sh
```

If you don't use zsh:

```bash
./install.sh --no-zsh
```

Optional: enable soft line wrap in `micro` (writes to `~/.config/micro/settings.json`):

```bash
./install.sh --micro
```
