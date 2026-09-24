" Plugin-free config, meant to behave the same on every host.
set nocompatible
filetype plugin indent on
syntax on

set encoding=utf-8
set background=dark
set number relativenumber
set ruler showcmd showmatch
set hidden
set backspace=indent,eol,start
set scrolloff=4
set wildmenu
set mouse=a
set splitright splitbelow

set expandtab shiftwidth=4 tabstop=4 softtabstop=4
set autoindent

set ignorecase smartcase incsearch hlsearch
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" Keep swap/backup/undo files out of the working directory
for s:dir in ['swap', 'backup', 'undo']
    call mkdir(expand('~/.vim/' . s:dir), 'p', 0700)
endfor
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set undodir=~/.vim/undo//
set undofile

" Reopen files at the last cursor position
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif

autocmd FileType yaml,json,html,css,javascript,typescript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType make setlocal noexpandtab
