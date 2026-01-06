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

## Usage

```bash
shellrig list
shellrig hello
```

## Dev

```bash
make lint
make test
```
