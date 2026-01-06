# shellrig

My own shell scripts I use daily.

## Install

Symlink scripts into `~/.local/bin`:

```bash
./install.sh
```

Ensure `~/.local/bin` is on your PATH (zsh example):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

Enable zsh functions/aliases (this repo links `~/.config/zsh/shellrig.zsh`):

```bash
echo 'source "$XDG_CONFIG_HOME/zsh/shellrig.zsh"' >> ~/.zshrc
```

## Usage

```bash
shellrig list
shellrig hello

# zsh plugin
gdelta --help
gclone --help
gpick --help
co --help

# project
pr <query>   # cd into project root
cwd <query>  # prints project root

# open files
co <query>        # filtered to “code-ish” files
co -a <query>     # all files
```

## Homebrew Tools

Suggested installs:

```bash
brew install bat micro eza fd ripgrep fzf git-delta gh jq tmux shellcheck
```

What they’re used for:

- `bat`: previews in `co` (fallback to `sed` if missing)
- `micro`: default `$EDITOR` for `co`
- `eza`: `ls/ll/la/lt` aliases
- `fd`: file search backend for `co`, `cwd`, `pr`
- `ripgrep` (`rg`): general-purpose fast search (optional; not required by current `shellrig` functions)
- `fzf`: interactive picker UI for `co`, `gpick`, `cwd`, `pr`
- `git-delta` (`delta`): pager for `gdelta`
- `gh`: GitHub integration for `gpick`/`gclone`
- `jq`: JSON parsing for `gpick`
- `tmux`: `tks` alias
- `shellcheck`: lint (`make lint`)

Optional:

- `zinit` (`zi`): zsh plugin manager (if you want to manage `shellrig` + other plugins via `zi`)

## Git Tools

These are zsh functions + global git aliases (not `bin/` scripts), so keep them in the zsh plugin.

```bash
# zsh functions (from `source "$XDG_CONFIG_HOME/zsh/shellrig.zsh"`)
gdelta [staged|-- <git diff args>]      # pretty diff via delta
gpick <search terms>                    # repo picker (gh search + fzf)
gclone [--p|--ex] <terms|owner/repo>    # clone helper (gh search + git clone)

# git “external subcommands” (executables on PATH)
git new <branch>                         # runs `git-new` (create branch + push -u origin)
git cmp <commit message>                 # runs `git-cmp` (add -A + commit + push)
```

Notes:

- All of these can change remotes / push / clone; treat them as “power tools”.
- `git cmp` stages **everything** (`git add -A`) including deletions.

Migration:

- If you previously had `alias.new` / `alias.cmp` in `~/.gitconfig`, remove them so `git` uses the executables:
  - `git config --global --unset alias.new`
  - `git config --global --unset alias.cmp`

## Dev

```bash
make lint
make test
```

## ChezMoi

Use `chezmoi` to keep dotfiles private, and pull `shellrig` as an external repo. See `docs/chezmoi.md`.
