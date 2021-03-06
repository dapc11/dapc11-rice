" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'ap/vim-css-color'
Plug 'chriskempson/base16-vim'
Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-rooter'
Plug 'dense-analysis/ale'
Plug 'Yggdroot/indentLine'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'terryma/vim-expand-region'
Plug 'davidhalter/jedi-vim'
Plug 'sheerun/vim-polyglot'
call plug#end()

let g:rooter_patterns = ['.git', 'src', 'pom.xml', 'Makefile', '*.sln', 'build/env.sh']
let g:rooter_change_directory_for_non_project_files = 'home'
let g:indentLine_setConceal = 0
let g:python3_host_prog = '~/venv/dev/bin/python3'
" let g:jedi#environment_path = "dev"
let g:ale_echo_msg_format = '[%linter%] %code: %%s [%severity%]'
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_lint_on_text_changed = 'never'
" Make sure to pip install python-language-server yamllint
let g:ale_linters = {'python': ['pylint', 'flake8']}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['add_blank_lines_for_python_control_statements', 'black', 'isort'],
\}
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif
"set omnifunc=ale#completion#OmniFunc
let g:ale_python_auto_pipenv = 1
let g:ale_python_pyls_auto_pipenv = 1
let g:ale_python_pyls_config = {}
let g:ale_python_pyls_executable = 'pyls'
let g:ale_python_pyls_options = ''
let g:ale_python_pyls_use_global = 1
nmap L <Plug>(ale_fix)
nmap l <Plug>(ale_lint)

let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_stubs_command = ""
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>u"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#rename_command = "<leader>r"

" Write this in your vimrc file
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
" inoremap <silent> <C-Space> <C-\><C-O>:ALEComplete<CR>

map <C-w> <Plug>(expand_region_expand)
map <C-W> <Plug>(expand_region_shrink)
