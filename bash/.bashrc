# ~/.bashrc: interactive shells. Per-host overrides go in ~/.bashrc.local (sourced last).

[[ $- != *i* ]] && return

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
shopt -s histappend
shopt -s checkwinsize

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

if grep -qi microsoft /proc/version 2>/dev/null; then
    export IS_WSL=1
    alias open='explorer.exe'
fi

test -f ~/.bashrc.local && . ~/.bashrc.local

# Built after ~/.bashrc.local so hosts can set PS1_BG / PS1_FG
PS1="\n\[\$(tput setab $PS1_BG)\]\[\$(tput setaf $PS1_FG)\]\h\[\$(tput sgr0)\]  [\$PWD] \n\$ "
