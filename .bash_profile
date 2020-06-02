if [ ! -n "$PS1_HOST" ]; then PS1_HOST=$HOSTNAME; fi

case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
    screen)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
esac

# Enable colors for ls, etc. Prefer ~/.dir_colors
if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dir_colors ]] ; then
        eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
        eval $(dircolors -b /etc/DIR_COLORS)
    fi
fi

export PS1="$(if [[ ${EUID} == 0 ]]; then echo '\[\033[38;5;1m\]\u@'; else echo ''; fi)\[\033[38;5;10m\]$PS1_HOST\[$(tput sgr0)\]\[\033[38;5;6m\][\w]:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"


PS2="> "
PS3="> "
PS4="+ "

# aliases are loaded from bashrc
test -f ~/.bashrc && source ~/.bashrc

test -f ~/.sh_local && source ~/.sh_local
