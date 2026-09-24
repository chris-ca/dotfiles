# ls and coloring
alias l='ls -lhF'
alias ll='ls -lhF'
alias la='ls -AlhF'
alias ls="ls --color=auto"
alias grep="grep --colour=auto"
alias randstring="tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo"

alias cw..='cd ..'
alias ..='cd ..'

alias g='git'
alias ports='netstat -tulanp'
alias du='du -hsc'
alias df='df -h'
alias kmsg='dmesg | perl -ne "BEGIN{\$a= time()- qx!cat /proc/uptime!}; s/\[\s*(\d+)\.\d+\]/localtime(\$1 + \$a)/e; print \$_;"'
alias screen='_ssh_auth_save ; export HOSTNAME=$(hostname) ; screen'
alias tmux='_ssh_auth_save ; export HOSTNAME=$(hostname) ; tmux'
