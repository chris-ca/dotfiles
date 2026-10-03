# Updates: September 2026 overhaul

This document explains everything that changed in the September 2026 cleanup, what behaves differently day to day, and how to move an existing host to the new setup.

- [Updating an existing host](#updating-an-existing-host)
- [Repository layout and install](#repository-layout-and-install)
- [Per-host files](#per-host-files)
- [Shell: prompt, history, aliases](#shell-prompt-history-aliases)
- [Readline (`.inputrc`)](#readline-inputrc)
- [Git](#git)
- [SSH](#ssh)
- [tmux](#tmux)
- [Vim](#vim)
- [Scripts (`bin`)](#scripts-bin)
- [Removed](#removed)
- [Behaviour changes to watch for](#behaviour-changes-to-watch-for)

---

## Updating an existing host

```sh
sudo apt install stow
cd ~/.dotfiles && git pull
./install.sh
```

Then check these, and create the files the host needs:

1. **`~/.sh_local`**: if it exists, `install.sh` prints a note, because the file is no longer read. Move `PATH`/`export` lines to `~/.profile.local`, and everything interactive (nvm, prompt colour, aliases) to `~/.bashrc.local`. Then delete it.
2. **Git email**: `user.email` is no longer in the shared config, so it doesn't appear in the public repo. Add it per host:
   ```ini
   # ~/.gitconfig.local
   [user]
   	email = you@example.com
   ```
   Without it, git asks for an email on the first commit.
3. **`safe.directory` entries**: if the host needs any (e.g. `/srv`), put them in `~/.gitconfig.local` too.
4. **Restart**: log out and back in, or open a new terminal. Restart tmux, or reload its config with `prefix r`.

`install.sh` never deletes anything. Any existing file it would replace is moved to `~/.dotfiles-backup/<timestamp>/`. An existing `~/.ssh/config` is the one exception: it's moved to `~/.ssh/config.d/local` instead, so its host entries keep working.

---

## Repository layout and install

**Before:** all files lived in the repo root. `install.sh` ran `ln -sf` for each file, which silently overwrote existing files. It linked a `~/.vimrc` that didn't exist and assumed the repo was at `~/.dotfiles`.

**Now:** each directory is a [GNU stow](https://www.gnu.org/software/stow/) package, and its contents mirror `$HOME`:

| Package | Installs |
|---------|----------|
| `bash`  | `~/.profile`, `~/.bash_profile`, `~/.bashrc`, `~/.bash_aliases`, `~/.inputrc` |
| `git`   | `~/.gitconfig`, `~/.config/git/ignore` |
| `tmux`  | `~/.tmux.conf` |
| `ssh`   | `~/.ssh/config`, `~/.ssh/rc` |
| `vim`   | `~/.vimrc` |
| `bin`   | `~/.local/bin/randstring`, `~/.local/bin/ta` |

`install.sh`:
- **Packages:** installs all of them by default. To install a subset, name them: `./install.sh bash git`.
- **Location:** works wherever the repo is cloned.
- **Re-running** is safe; links that are already correct are left alone.
- **Old links:** removes broken links left over from the old install script (`~/.gitignore`, `~/.gitignore_global`, `~/.ssh_rc`, …).
- **Directories:** never links a whole directory into the repo, only individual files. Without this, stow would link all of `~/.ssh` into the repo, and new keys would be written into the git checkout.
- **SSH config permissions:** sets `~/.ssh/config` to mode 600. ssh refuses a group-writable config, and a clone made under a permissive umask would otherwise have one.

To remove a package: `stow -d ~/.dotfiles -t ~ -D <package>`.

---

## Per-host files

Settings that differ per machine stay out of the repo. These files are all optional and never committed:

| File | Loaded by | Use for |
|------|-----------|---------|
| `~/.profile.local`  | end of `.profile` (login) | `PATH` additions, exported variables |
| `~/.bashrc.local`   | end of `.bashrc` (interactive) | nvm, host-only aliases, prompt colour |
| `~/.gitconfig.local`| `[include]` at end of `.gitconfig` | `user.email`, `safe.directory`, work identity |
| `~/.ssh/config.d/*` | `Include` at top of `.ssh/config` | host entries (names, IPs, users, keys) |

They replace the old `~/.sh_local`, which mixed environment and interactive settings in one file.

Example: colour production hosts red, so they stand out:

```sh
# ~/.bashrc.local
PS1_BG=$COL_RED
PS1_FG=$COL_WHITE
```

Available colours: `COL_BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GRAY ORANGE TURQUOISE WINERED`.

---

## Shell: prompt, history, aliases

### The new prompt

```
myhost  [/home/chris/dotfiles] (master)
+$ false

myhost  [/home/chris/dotfiles] (master)
+[1] $ vim README.md          ← press Esc here…

myhost  [/home/chris/dotfiles] (master)
:$                            ← …and the + becomes :
```

| Part | Meaning |
|------|---------|
| `myhost` | Hostname, shown as a coloured label (black on white by default; set it per host, see above). |
| `[/home/…]` | Full current directory. |
| `(master)` | Current git branch. Only shown inside a git repository. |
| blank line | Separates each command's output from the next prompt. |
| `+` / `:` | **vi mode indicator.** `+` = insert mode (typing), `:` = normal mode (after Esc, move with `h j k l w b`, `0`, `$`, …). Press `i` or `a` to type again. |
| `[1]` (red) | **Exit code of the last command**, shown only when it failed (non-zero). `[127]` = command not found, `[130]` = interrupted with Ctrl-C. |
| `$` / `#` | `#` when you are root. |

### History
- **Written immediately:** each command is saved to `~/.bash_history` as soon as it runs, not when the shell exits. Closing a tmux pane or losing an SSH connection no longer loses history. Other open shells see new entries after `history -n` or in a new shell.
- **Timestamps:** `history` now shows when each command ran (`2026-09-24 14:03:11  git pull`).
- **Size:** 10,000 lines in memory and 20,000 in the file (was 1,000/2,000). Duplicates and commands starting with a space are still not saved.

### Other shell changes
- **`cdspell`:** `cd` fixes small typos in directory names (`cd /ect` → `/etc`).
- **`globstar`:** `**` matches recursively (`ls **/*.py`).
- **`EDITOR`/`VISUAL` = `vim`** everywhere; before, it was `/usr/bin/vi` in the shell and `vim` in git.
- **Locale:** `LANG=en_US.UTF-8` is set if that locale exists on the host, otherwise `C.UTF-8`, so UTF-8 works everywhere. `LC_ALL` and `LANGUAGE` are no longer forced, which caused `setlocale` warnings on minimal VPSes. `LC_*` variables naming a locale the host lacks (typically forwarded by ssh from the client, e.g. `LC_MONETARY=de_CH.UTF-8`) are unset at login, so `sudo apt upgrade` no longer prints perl/apt-listchanges locale warnings.
- **`TERM`:** no longer forced to `xterm-256color`, which broke colours and keys inside tmux. The terminal and tmux now set it. Only a plain `xterm` is upgraded to `xterm-256color` (if the host knows it), so the prompt colours also work outside tmux.
- **WSL:** detected automatically. `$IS_WSL` is set, and `open <file>` opens it in Windows.
- **File roles:** `.profile` holds the environment, `.bashrc` holds interactive settings, and `.bash_profile` just loads both. Before, the same settings were spread over all three.

### Aliases

| Alias | Change |
|-------|--------|
| `ports` | Now `ss -tulpn`. `netstat` isn't installed on current Debian. |
| `kmsg`  | Now `dmesg -T` (human-readable timestamps). It replaces a Perl one-liner. |
| `du`    | **Removed.** `du` behaves normally again; use `du -hsc` explicitly. |
| `cw..`  | **Removed** (typo). |
| `randstring` | Now a script, see [bin](#scripts-bin). |
| `tmux`, `screen` | **Removed.** These wrappers existed to fix SSH agent forwarding; `~/.ssh/rc` does that now. |

Unchanged: `l`, `ll`, `la`, `ls`, `grep`, `..`, `g`, `df`.

---

## Readline (`.inputrc`)

These apply to bash and to other programs that use readline (`python`, `psql`, `sqlite3`, …):

- **History search:** with some text typed, Up/Down search only history lines that start with it. Type `git ` and press Up to step through your recent git commands. In vi normal mode, `k`/`j` do the same.
- **Case-insensitive completion:** `cd doc<Tab>` completes `Documents`.
- **Completion listing:** all matches are listed on the first Tab instead of the second.
- **Coloured listing:** completion lists are coloured by file type, and symlinked directories get a trailing `/`.
- **Vi mode indicator:** the `+`/`:` shown in the prompt.

---

## Git

### New defaults

| Setting | Effect |
|---------|--------|
| `push.default = simple` | `git push` pushes only the current branch. Before, it was `matching`, which pushed **every** local branch with a same-named remote branch. |
| `push.autoSetupRemote = true` | On the first push of a new branch, git sets up tracking automatically; no `-u origin <branch>` needed. |
| `pull.ff = only` | `git pull` refuses when your branch and the remote have both moved on, instead of creating a merge commit. Then run `git pull --rebase`. |
| `fetch.prune = true` | Remote branches that were deleted on the server disappear locally on fetch. |
| `rebase.autoStash = true` | Rebasing with uncommitted changes stashes them first and restores them afterwards. |
| `diff.algorithm = histogram` | More readable diffs when code moves around. |
| `merge.conflictStyle = diff3` | Conflicts also show the original text (the part between the `\|\|\|\|\|\|\|` and `=======` lines), not just both sides. |
| `rerere.enabled = true` | Git remembers how you resolved a conflict and reapplies it if the same conflict comes up again. |
| `commit.verbose = true` | The commit message editor shows the full diff below the message. |
| `init.defaultBranch = main` | New repositories start on `main`. |

`core.fileMode = false` was **removed**. It hid exec-bit changes in every repository.

These values also work with older git versions. The newer variants (`zdiff3`, `help.autocorrect=prompt`) would make git exit with an error on older VPSes.

### Global ignore
Moved from `~/.gitignore_global` to `~/.config/git/ignore`, git's standard location. It now covers:
`*.sw?`, `*.log`, `*.pyc`, `__pycache__`, `**/.claude/settings.local.json`, `.env`, `.venv/`, `node_modules/`, `.DS_Store`, `Thumbs.db`, and `*:Zone.Identifier` (created when copying files from Windows into WSL).

### Aliases
Unchanged: `s`, `b`, `c`, `l`, `lg`, `push-test`, `forcepush`.

---

## SSH

### `~/.ssh/config` (new)
Shared defaults for every host:
- **Keepalive** every 60 seconds (`ServerAliveInterval 60`), so idle sessions to VPSes don't drop.
- **Agent:** keys are added to the agent on first use (`AddKeysToAgent yes`).
- **Connection reuse** (`ControlMaster`/`ControlPersist 10m`): after the first connection to a host, further `ssh`, `scp`, `rsync` and `git push` to it connect instantly for 10 minutes.

Host entries go in `~/.ssh/config.d/` (not tracked). They are read first, so they override the defaults:

```
# ~/.ssh/config.d/servers
Host web1
    HostName 203.0.113.10
    User deploy
    ForwardAgent yes
```

**Connection reuse caveats**
- A reused connection keeps the options of the first one. If you connect without `-A` first, a later `ssh -A` to the same host doesn't forward the agent until the connection closes. Set `ForwardAgent yes` in the host entry for hosts where you always need it.
- If a connection hangs after a network change: `ssh -O exit <host>`.

### `~/.ssh/rc` (fixed)
This keeps SSH agent forwarding working inside tmux after you reconnect. It was previously installed as `~/.ssh_rc`, a path sshd never runs, so it never worked. The `tmux` alias wrapper covered for it using a different socket name. Now there is a single mechanism:
- `~/.ssh/rc` points `~/.ssh/ssh_auth_sock` at the current agent on every login.
- tmux always uses that path.
- `~/.ssh/rc` also handles X11 forwarding, because sshd stops handling it itself when this file exists.

---

## tmux

- **Scrollback:** 50,000 lines (was 2,000). This applies to new panes.
- **Window numbering:** windows are renumbered when one closes, so there are no gaps like 1, 3, 4.
- **Current directory:** splits (`prefix "`, `prefix %`) and new windows (`prefix c`) open in the current pane's directory.
- **Clipboard:** text copied in copy mode reaches your **local** clipboard, also from tmux running on a VPS over SSH. This uses a terminal feature called OSC 52. It works in Windows Terminal, iTerm2, WezTerm, kitty and Alacritty, but not in GNOME Terminal. On WSL, tmux-yank also uses `clip.exe`.
- **Terminal type:** `tmux-256color` (or `screen-256color` on hosts without that terminfo entry), so colours and special keys work correctly inside tmux. 256 colours and truecolor are enabled even when the outer terminal only reports `TERM=xterm`, and `ta` starts tmux in UTF-8 mode.
- **Plugins install themselves:** on a new host, the first tmux start installs TPM and all plugins (tmux-sensible, tmux-yank, tmux-resurrect). Before, TPM's standard bootstrap only downloaded TPM, and the plugins never installed. There's no longer any need to press `prefix I`, except after adding a new plugin.

Unchanged: prefix `C-a`, vi copy mode, `prefix r` to reload, `prefix m` / `prefix M` to turn mouse on/off, tmux-resurrect (`prefix C-s` save, `prefix C-r` restore).

---

## Vim

The Neovim config was removed, and there's a new plugin-free `~/.vimrc` that behaves the same on every host:

- **Display:** syntax highlighting, and line numbers relative to the cursor.
- **Indentation:** 4 spaces, or 2 for YAML, JSON, HTML, CSS and JS/TS. Makefiles keep tabs.
- **Search:** case-insensitive unless the search contains uppercase, highlighted as you type. Press **Esc Esc** to clear the highlighting.
- **Undo history is kept between sessions:** you can undo changes after closing and reopening a file.
- **Swap, backup and undo files** go to `~/.vim/swap`, `~/.vim/backup` and `~/.vim/undo`, not next to the file being edited.
- **Last position:** files reopen at the last cursor position.
- **Mouse** enabled. Splits open to the right or below.

---

## Scripts (`bin`)

These are installed to `~/.local/bin`, which is on `PATH`.

**`randstring [length] [charset]`** generates a random string (replaces the alias):
```sh
randstring              # 16 chars, A-Za-z0-9
randstring 32           # 32 chars
randstring 40 'a-f0-9'  # hex
```

**`ta [name]`** attaches to a tmux session, creating it if needed (default name: `main`):
```sh
ta          # attach to "main", or create it
ta work     # attach to "work", or create it
```
Inside tmux it switches to the session instead of starting tmux within tmux. Names must match exactly (`ta ma` won't pick `main`).

---

## Removed

| What | Why |
|------|-----|
| Neovim config (`neovim.init`) | Not used. It loaded a `lua/pyright.lua` file that was never in the repo, so it errored on every new host. |
| `.screenrc` | Replaced by tmux. |
| i3 config | Not used. It was the auto-generated default config and was never linked by `install.sh`. |
| `256colorstest.pl` | A colour test script copied from xterm, not configuration. |
| `~/.sh_local` support | Replaced by `~/.profile.local` and `~/.bashrc.local`. |
| `_ssh_auth_save`, `tmux`/`screen` wrappers | Replaced by `~/.ssh/rc`. |
| Debian skeleton comments, commented-out blocks | Noise. |

---

## Behaviour changes to watch for

- **`git pull` can refuse** when your branch and the remote have both changed (`fatal: Not possible to fast-forward`). Run `git pull --rebase`.
- **`git push` without arguments** pushes only the current branch.
- **`du`** shows normal output again (no `-hsc`).
- **Git asks for an email** on the first commit on a host that has no `~/.gitconfig.local` with one.
- **Agent forwarding over a reused SSH connection:** see the [SSH caveats](#ssh).
- **Up arrow** searches history for what you've already typed. On an empty line it behaves as before.
