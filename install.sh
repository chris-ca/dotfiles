#!/bin/sh
INSTALLDIR=$1

if [ -z "$INSTALLDIR" ]; then
    echo "INSTALLDIR \$1 must be specified (usually \$HOME)";
fi

cd $INSTALLDIR
ln -f -s .dotfiles/.bash_aliases
ln -f -s .dotfiles/.bash_profile
ln -f -s .dotfiles/.bashrc
ln -f -s .dotfiles/.gitconfig
ln -f -s .dotfiles/.gitignore
ln -f -s .dotfiles/.gitignore_global
ln -f -s .dotfiles/.profile
ln -f -s .dotfiles/.screenrc
ln -f -s .dotfiles/.ssh_rc
ln -f -s .dotfiles/.tmux.conf
ln -f -s .vim/.vimrc
