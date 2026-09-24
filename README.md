# dotfiles
Personal shell, git and tmux configuration shared across VPSes, workstations and WSL.

## What changed (September 2026)
- **Install via GNU stow.** Packages: `bash git tmux ssh vim bin`. Existing files are backed up to `~/.dotfiles-backup/`, never overwritten.
- **Per-host settings live outside the repo:** `~/.profile.local`, `~/.bashrc.local`, `~/.gitconfig.local` (incl. `user.email`) and `~/.ssh/config.d/`. `~/.sh_local` is no longer read.
- **New prompt:** shows the git branch, `[n]` in red when the last command failed, and `+`/`:` for vi insert/normal mode. History is saved immediately, with timestamps.
- **Safer git defaults:** `push.default=simple` (was `matching`) and `pull.ff=only`, which means use `git pull --rebase` when branches have diverged.
- **SSH and tmux:** shared ssh config with keepalive and connection reuse; agent forwarding in tmux works again; tmux plugins install themselves.
- **Removed:** Neovim, screen, i3 configs.

Details, and how to update an existing host: **[UPDATES.md](UPDATES.md)**.

## Install
```sh
sudo apt install stow
git clone https://github.com/chris-ca/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh              # all packages: bash git tmux ssh vim bin
~/.dotfiles/install.sh bash git     # or a subset
```
Existing files that would be replaced are moved to `~/.dotfiles-backup/<timestamp>/`.
Re-running is safe. A leftover legacy `~/.sh_local` is reported; move its contents to the files below. To unlink a package: `stow -d ~/.dotfiles -t ~ -D <package>`.

## Packages
| Package | Files |
|---------|-------|
| `bash`  | `.profile` (environment), `.bash_profile`, `.bashrc`, `.bash_aliases`, `.inputrc` |
| `git`   | `.gitconfig`, `.config/git/ignore` (global ignores) |
| `tmux`  | `.tmux.conf` (TPM and plugins install themselves on first start) |
| `ssh`   | `.ssh/config` (keepalive, connection reuse), `.ssh/rc` (stable agent socket for tmux) |
| `vim`   | `.vimrc` (no plugins; swap/undo files in `~/.vim/`) |
| `bin`   | `~/.local/bin` scripts: `randstring [len] [charset]`, `ta [name]` (tmux attach-or-new) |

## Per-host overrides (not tracked)
- `~/.profile.local`: sourced at the end of `.profile` (login environment), e.g. extra `PATH` entries.
- `~/.bashrc.local`: sourced at the end of `.bashrc` (interactive shells), e.g. nvm, or `PS1_BG=$COL_RED` to colour production hosts.
- `~/.ssh/config.d/*`: host entries, included before the shared defaults so they take precedence. An existing `~/.ssh/config` is moved to `config.d/local` on install.
- `~/.gitconfig.local`: included by `.gitconfig`, e.g. `[safe] directory = /srv` or a work email.
