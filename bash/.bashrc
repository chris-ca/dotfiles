# ~/.bashrc: interactive shells. Per-host overrides go in ~/.bashrc.local (sourced last).

[[ $- != *i* ]] && return

# Terminals reporting plain "xterm" nearly all support 256 colours; upgrade only that case
if [ "$TERM" = xterm ] && infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# 256-color codes, used for the host label in the prompt
COL_BLACK="16"
COL_RED="160"
COL_GREEN="28"
COL_YELLOW="184"
COL_BLUE="33"
COL_MAGENTA="161"
COL_CYAN="51"
COL_WHITE="231"
COL_GRAY="251"
COL_ORANGE="208"
COL_TURQUOISE="43"
COL_WINERED="88"

PS1_BG=$COL_WHITE
PS1_FG=$COL_BLACK

# History: no duplicates or space-prefixed lines, append instead of overwrite
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT='%F %T '
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell globstar

set -o vi

if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# __git_ps1 for the prompt; bash-completion usually loads it already
if ! type __git_ps1 >/dev/null 2>&1; then
    for f in /usr/lib/git-core/git-sh-prompt /usr/share/git-core/contrib/completion/git-prompt.sh; do
        [ -f "$f" ] && . "$f" && break
    done
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
    export IS_WSL=1
    alias open='explorer.exe'
fi

test -f ~/.bashrc.local && . ~/.bashrc.local

# Colors are resolved after ~/.bashrc.local so hosts can set PS1_BG / PS1_FG
_ps1_host="\[$(tput setab $PS1_BG)$(tput setaf $PS1_FG)\]\h\[$(tput sgr0)\]"
_ps1_err="\[$(tput setaf $COL_RED)\]"
_ps1_reset="\[$(tput sgr0)\]"

# Runs before each prompt: keep the exit code, and write history immediately
# so other shells (tmux panes) can pick it up with `history -n`
_prompt_command() {
    local status=$?
    history -a
    PS1="\n$_ps1_host  [\$PWD]"
    type __git_ps1 >/dev/null 2>&1 && PS1+='$(__git_ps1 " (%s)")'
    PS1+=" \n"
    [ $status -ne 0 ] && PS1+="$_ps1_err[$status]$_ps1_reset "
    PS1+='\$ '
}
PROMPT_COMMAND="_prompt_command${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
