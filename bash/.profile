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

# Drop LC_* naming locales not installed here: ssh forwards the client's LC_*
# (SendEnv/AcceptEnv) and sudo keeps them, so perl/apt-listchanges would warn
_locales=$(printf '%s\n' "$_locales" | tr 'A-Z' 'a-z')
for _v in LC_ALL LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES \
          LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION; do
    eval "_l=\${$_v-}"
    [ -n "$_l" ] || continue
    _l=$(printf '%s' "$_l" | tr 'A-Z' 'a-z' | sed 's/utf-8/utf8/')
    printf '%s\n' "$_locales" | grep -qxF "$_l" || unset "$_v"
done
unset _l _v _locales

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
