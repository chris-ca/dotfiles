#!/bin/sh
for dotfile in `find .dotfiles/ -type f -name ".*"`;
do
	ln -s $dotfile
done
