" Shared Vim configuration for Arch, Ubuntu, Kali and macOS
set nocompatible
syntax enable
set number
set relativenumber
set cursorline
set showmatch
set hidden
set mouse=a
set scrolloff=5
set splitbelow
set splitright
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set undofile
set backupskip=/tmp/*
if has('termguicolors')
  set termguicolors
endif
set background=dark
silent! colorscheme oxocarbon
