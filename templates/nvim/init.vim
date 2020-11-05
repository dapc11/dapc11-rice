nnoremap <SPACE> <Nop>
let mapleader =" "

" Plugins, autoinstall vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
endif
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'
Plug 'godlygeek/tabular'
Plug 'airblade/vim-gitgutter'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --omnisharp-completer' }
Plug 'ap/vim-css-color'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'
Plug 'chriskempson/base16-vim'
Plug 'jiangmiao/auto-pairs'
call plug#end()

" Enable alignment
let g:neoformat_basic_format_align = 1

" Enable tab to space conversion
let g:neoformat_basic_format_retab = 1

" Enable trimmming of trailing whitespace
let g:neoformat_basic_format_trim = 1

""""
" Requires gvim
" paste with shift+insert
noremap <Leader>Y "*y<CR>
noremap <Leader>P "*p<CR>
" paste with ctrl+v
noremap <Leader>y "+y<CR>
noremap <Leader>p "+p<CR>

" Some basics:
nnoremap c "_c
set go=a
set mouse=a
set nohlsearch
set clipboard+=unnamedplus
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set nocompatible
filetype plugin on
syntax on
set encoding=utf-8
set number relativenumber
set colorcolumn=80
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

nnoremap <buffer> <silent> <leader>gd :YcmCompleter GoTo<CR>
nnoremap <buffer> <silent> <leader>gr :YcmCompleter GoToReferences<CR>
nmap <leader>q <plug>(YCMHover)
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_key_invoke_completion = '<c-j>'
let g:ycm_complete_in_strings = 1
let g:ycm_key_list_stop_completion = ['<C-y>', '<CR>']
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''

" Colorscheme
"set bg=dark
"let base16colorspace=256  " Access colors present in 256 colorspace
set termguicolors
colorscheme {{vim_colorscheme}}

hi ColorColumn guifg={{base01}} guibg={{base01}}
hi LineNr guifg={{base02}} guibg={{base00}}
hi CursorLineNr guifg={{base05}} guibg={{base00}}

" Enable autocompletion:
set wildmode=longest,list,full
" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow splitright

" Shortcutting split navigation, saving a keypress:
map <C-M-left> <C-w>h
map <C-M-down> <C-w>j
map <C-M-up> <C-w>k
map <C-M-right> <C-w>l
map <leader>q :q<CR>

" Commenting
map <C-_> gcc

" Replace ex mode with gq
map Q gq
" delete visual and paste
map <leader>p "_dP

" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Save file as sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritepre * %s/\n\+\%$//e

" When shortcut files are updated, renew bash and ranger configs with new material:
autocmd BufWritePost files,directories !shortcuts

" fzf
let g:fzf_nvim_statusline = 0 " disable statusline overwriting

command! -bang -nargs=* GGrep call fzf#vim#grep('git grep --line-number -- '.shellescape(<q-args>), 0, fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --hidden --line-number --no-heading --color=always --smart-case %s ~ || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

nnoremap <silent> <leader><leader>g :GGrep<cr>
nnoremap <silent> <leader><leader>G :GFiles<cr>
nnoremap <silent> <leader><leader>f :BLines<cr>
nnoremap <silent> <leader><leader>F :RG<cr>
nnoremap <silent> <leader><leader>n :Files<cr>
nnoremap <silent> <Leader><leader>N :FZF ~<cr>
nnoremap <silent> <leader><leader>b :Buffers<CR>
nnoremap <silent> <leader><leader>w :Windows<CR>
nnoremap <silent> <leader><leader>l :BLines<CR>
nnoremap <silent> <leader><leader>p :History<CR>

nnoremap <silent> <A-left> :bp<CR>
nnoremap <silent> <A-right> :bn<CR>
nnoremap <silent> <A-up> :Buffers<CR>

set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__

" The Silver Searcher
if executable('ag')
    let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
    set grepprg=ag\ --nogroup\ --nocolor
endif

" UndoTree
nnoremap <leader>u :UndotreeShow<CR>

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

" Tabular
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

au FileType python setlocal formatprg=autopep8\ -

" Turns off highlighting on the bits of code that are changed.
" So the line that is changed is highlighted,
" but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

fun! HighlightTodo()
    match none
    match Error /TODO/
endfunc

autocmd BufReadPost,BufNewFile * :call HighlightTodo()
autocmd BufWritePre * :call TrimWhitespace()
highlight EndOfBuffer ctermfg=black
if (&term =~ '^xterm' && &t_Co == 256)
  set t_ut= | set ttyscroll=1
endif
