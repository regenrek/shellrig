## mdclip

Fast macOS workflow for “screenshot in clipboard -> file in repo -> markdown on clipboard”.

### Install deps

```bash
brew install pngpaste webp
# optional (extra png compression)
brew install oxipng
```

### Usage

1) Take screenshot to clipboard (e.g. iScreenshotter).
2) In the repo:

```bash
mdclip
```

This writes an image into `public/` at the git repo root (default: WebP), and prints + copies the Markdown image link.

### Naming / options

```bash
mdclip login
mdclip login png
```

Defaults:

```bash
export MDSHOT_MAX=1600
export MDSHOT_Q=78
export MDSHOT_FMT=webp
```

### Vim

Insert markdown directly:

```vim
:r !mdclip
```

### micro

Run `mdclip` in a shell, then paste the line into micro.

