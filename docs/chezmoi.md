## chezmoi integration (recommended)

Goal: keep `~/.zshrc` + private ops in your private dotfiles repo, but pull `shellrig` (public) as an external, and run its installer deterministically.

### 1) Track `shellrig` as an external

Add to `~/.config/chezmoi/.chezmoiexternal.toml`:

```toml
[".local/share/shellrig"]
type = "git-repo"
url = "https://github.com/regenrek/shellrig.git"
refreshPeriod = "168h"
```

### 2) Run install after apply

Add a chezmoi hook file:

- `~/.config/chezmoi/run_once_after_10-shellrig-install.sh.tmpl`

```bash
#!/usr/bin/env bash
set -euo pipefail

repo="$HOME/.local/share/shellrig"
cd "$repo"
./install.sh
```

### 3) Source the zsh plugin

In your (private) `~/.zshrc`:

```zsh
source "$XDG_CONFIG_HOME/zsh/shellrig.zsh"
```

