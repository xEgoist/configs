
" To be Removed whenever zig is integrated to Vim
call plug#begin('~/.vim/plugged')
   Plug 'ziglang/zig.vim'
call plug#end()

set nu rnu
set tw=792034
set cc=80
set nobackup
set noswapfile
set noundofile
set background=dark
set expandtab
set tabstop=4
set shiftwidth=4
set mouse=a
syntax on
syntax enable
colorscheme desert
:hi Normal guibg=NONE ctermbg=NONE
