" Neovim configuration
" Load vim config for compatibility
source ~/.vimrc

" Neovim specific settings
set termguicolors             " enable true color support
set undofile                  " persistent undo
set undodir=~/.config/nvim/undo

" Better defaults for neovim
set updatetime=300
set signcolumn=yes
set completeopt=menuone,noselect

" Terminal mode mappings
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" Create undo directory if it doesn't exist
if !isdirectory($HOME."/.config/nvim/undo")
    call mkdir($HOME."/.config/nvim/undo", "p")
endif