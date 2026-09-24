#!/bin/sh
# Link dotfile packages into $HOME with GNU stow.
# Usage: ./install.sh [package ...]   (default: bash git tmux ssh vim)
# Conflicting files are moved to ~/.dotfiles-backup/<timestamp>/ first.
set -eu

REPO=$(cd "$(dirname "$0")" && pwd)
PACKAGES=${*:-bash git tmux ssh vim}
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

command -v stow >/dev/null || { echo "stow is not installed (apt install stow)" >&2; exit 1; }

# Dangling symlinks left behind by the old ln-based install.sh
for f in .gitignore .gitignore_global .ssh_rc .screenrc .vimrc; do
    if [ -L "$HOME/$f" ] && [ ! -e "$HOME/$f" ] && case $(readlink "$HOME/$f") in *dotfiles*) true;; *) false;; esac; then
        rm "$HOME/$f"
    fi
done

mkdir -p -m 700 "$HOME/.ssh"

for pkg in $PACKAGES; do
    [ -d "$REPO/$pkg" ] || { echo "unknown package: $pkg" >&2; exit 1; }
    (cd "$REPO/$pkg" && find . -type f -o -type l) | sed 's|^\./||' | while read -r rel; do
        target="$HOME/$rel"
        if [ -e "$target" ] || [ -L "$target" ]; then
            # already linked by stow: nothing to do
            [ "$(readlink -f "$target")" = "$REPO/$pkg/$rel" ] && continue
            mkdir -p "$BACKUP/$(dirname "$rel")"
            mv "$target" "$BACKUP/$rel"
            echo "backed up ~/$rel -> $BACKUP/$rel"
        fi
    done
done

# --no-folding: never symlink whole directories like ~/.ssh or ~/.config into the repo
stow --dir="$REPO" --target="$HOME" --no-folding --restow $PACKAGES
echo "linked: $PACKAGES"

if [ -e "$HOME/.sh_local" ]; then
    echo "note: ~/.sh_local is no longer read; move its contents to ~/.profile.local (environment) or ~/.bashrc.local (interactive)" >&2
fi
