# ~/.profile: login environment for all shells (sourced by ~/.bash_profile).
# Per-host environment (PATH, exports) goes in ~/.profile.local (sourced last).

[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
export PATH

export EDITOR=vim
export VISUAL=vim

# Prefer en_US.UTF-8, fall back to C.UTF-8 (always present on glibc >= 2.35),
# and only request locales that exist, to avoid setlocale warnings
_locales=$(locale -a 2>/dev/null)
for _l in en_US C; do
    if printf '%s\n' "$_locales" | grep -qix "$_l\.utf-\?8"; then
        export LANG=$_l.UTF-8
        break
    fi
done
unset _l _locales

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
