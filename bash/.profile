# ~/.profile: login environment for all shells (sourced by ~/.bash_profile).
# Per-host environment (PATH, exports) goes in ~/.profile.local (sourced last).

[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
export PATH

export EDITOR=vim
export VISUAL=vim

# Only request a locale that is actually generated, to avoid setlocale warnings
if locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
    export LANG=en_US.UTF-8
fi

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
