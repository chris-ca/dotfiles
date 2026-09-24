# dotfiles
Personal shell, git and tmux configuration shared across VPSes, workstations and WSL.

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
