" Personal .vimrc file
" Always a work in progress.  
"
set rtp+=/Users/bantone/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim

" Pathogen Script to Install Additional Plugins
" NERDTree, Vundle, salt-vim, vim-fugitive, vim-go

execute pathogen#infect()

" Basics {
    set nocompatible				
    set encoding=utf-8
    syntax on
" }

" General {
    filetype off
    filetype plugin indent on 
"    set background=dark
    set backspace=indent,eol,start
    set backup				
    set backupdir=~/.vim/backup
    set directory=~/.vim/tmp
    set noerrorbells			
" }

" Split Navigations {
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" }

" Syntastic {
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" }

" VIM UI {
    if version >= 700
        set cursorcolumn
        set cursorline
    endif
    set incsearch
    set laststatus=2
    set linespace=0
    set matchtime=5
    set number
    set report=0
    set shortmess=aOstT
    set showcmd
    set showmatch
    set ruler
    set statusline=%<%h%r%m\ %f%=%-14.(%l,%c%V%)%V\ %P
" }

" Text Formatting / Layout {
    if version >= 700
	    set completeopt=
    endif
    set expandtab
    set formatoptions=lrq	
    set lbr
    set wrap
    set shiftwidth=4
    set softtabstop=4
    set tabstop=4
" }
"
" ColorScheme {
     set t_Co=256 " Expect terminal to support 256 colors
                  " OSX Terminal does not, use iTerm
     if version >= 700
         colorscheme one
"        colorscheme iceberg
"        colorscheme jellybeans
     else
         colorscheme oceandeep
     endif
" }

" NERDTree
"autocmd vimenter * NERDTree
"let g:NERDTreeWinSize=20
"let g:NERDTreeWinPos = "right"
