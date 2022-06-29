
let g:python3_host_prog = '$HOME/.pyenv/versions/py3nvim/bin/python'

" plug_version 8fdabfba0b5a1b0616977a32d9e04b4b98a6016a is from May 2022
let plug_version = '8fdabfba0b5a1b0616977a32d9e04b4b98a6016a'

" Auto-bootstrap vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/' . plug_version . '/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

	" General enhancement plugins
	Plug 'tpope/vim-obsession'

	" Themes
	Plug 'cormacrelf/vim-colors-github'
	Plug 'doums/darcula'
	Plug 'xdg/vim-darkluma'
	Plug 'tomasr/molokai'
	"Plug 'morhetz/gruvbox'

	" Code completion and linters
	Plug 'dense-analysis/ale'
	Plug 'hankei6km/ale-linter-actionlint.vim'

	Plug 'Shougo/context_filetype.vim' " Required by deoplete due to bug.
	if has('nvim')
		Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	else
		Plug 'Shougo/deoplete.nvim'
		Plug 'roxma/nvim-yarp'
		Plug 'roxma/vim-hug-neovim-rpc'
	endif

	"Plug 'vim-syntastic/syntastic'

	Plug 'aliou/bats.vim'

	" Golang specific
	"Plug 'fatih/vim-go', { 'tag': 'v1.24-rc.1', 'do': ':GoUpdateBinaries', }
	"Plug 'fatih/vim-go', { 'tag': 'v1.24-rc.1', }
	Plug 'fatih/vim-go'

	" Rust
	Plug 'rust-lang/rust.vim'

	" Docker
	Plug 'ekalinin/dockerfile.vim'
	Plug 'zchee/deoplete-docker'

	" AppleScript
	Plug 'mityu/vim-applescript'

	" HashiCorp
	Plug 'jvirtanen/vim-hcl'

call plug#end()

let g:gruvbox_contrast_dark = 'hard'
"colorscheme gruvbox " Default in case dark mode detection fails.

"" Ensure matching brace highlighting not more attention grabbing than
"" actual cursor.
augroup FixHighlighting
	autocmd!
	autocmd ColorScheme github highlight MatchParen cterm=bold ctermbg=lightyellow ctermfg=darkgrey
	autocmd ColorScheme github highlight StatusLine cterm=bold ctermbg=white ctermfg=darkgrey
	autocmd ColorScheme molokai highlight MatchParen cterm=bold ctermbg=black ctermfg=lightyellow
augroup END

""" Dark Mode handling
let s:darkModeEnabled = "NOT_SET"
function! Dark()
	colorscheme molokai
	if s:darkModeEnabled == "YES"
		return
	endif
	let s:darkModeEnabled = "YES"
endfunction
command! Dark call Dark()

function! Light() abort
	colorscheme github
	if s:darkModeEnabled == "NO"
		return
	endif
	let s:darkModeEnabled = "NO"
endfunction
command! Light call Light()

function! SysIsDarkMode()
	let result = trim(system("cat ~/.local/state/darkmode/color-palette"))
	if result == "Dark"
		return 1
	endif
	return 0
endfunction

function! AutoDarkMode(...) " The ... allows swallowing the timer ID passed by timer_start.
	if SysIsDarkMode()
		call Dark()
	else
		call Light()
	endif
endfunction
command! AutoDarkMode call AutoDarkMode()

""" general defaults
syntax on
set wrap
set number
set tabstop=4
set shiftwidth=4
set backspace=indent,eol,start " Enable 'normal' backspacing.
set signcolumn=yes             " Always show the gutter so errors don't cause line width to change.

if has('nvim')
	set clipboard+=unnamedplus " Use system clipboard on macOS (nvim)
else
	set clipboard+=unnamed     " Use system clipboard on macOS (vim)
endif

highlight SignColumn guibg=lightgrey
""" general defaults end

"""" ale config
let g:ale_linters = { 'go': ['gopls'], 'vim': ['vint'], 'yaml': ['actionlint']}
let g:ale_sh_shellcheck_options = '-x'
"" Use tab to cycle through completions.
"inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<TAB>"
"" Use shift tab to cycle backwards through completions.
"inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-TAB>
""""

"""" syntastic config
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"
"let g:syntastic_sh_shellcheck_args="-x"
"let g:syntastic_sh_checkers = [ "shellcheck" ]
"let g:syntastic_filetype_map = { "bats": "sh" }
""""

""" deoplete config
let g:deoplete#enable_at_startup = 1
" use ale as deoplete source
call deoplete#custom#option('sources', { '_': ['ale', ], })
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
""" deoplete end

""" vim-go config
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_list_type = "quickfix"
""" vim-go end

""" Go Text Templates syntax highlighting (see below for disabling problematic
""" indent rules when in yaml templates.
autocmd BufNewFile,BufRead *.tpl set filetype=gohtmltmpl

""" Filetype yaml yml yaml.tpl yml.tpl
" YAMLWhitespace sets tabs to 2 spaces, but does not set the filetype to YAML
" this is useful for YAML-like documents such as text templates that produce
" YAML.
function! YAMLWhitespace()
	" Indent to two spaces, do not reindent on colon or brace.
	setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab indentkeys-=<:}>
	" Disable all auto-indentation.
	setlocal indentexpr& cindent& smartindent& autoindent&
endfunction
autocmd BufNewFile,BufRead *.yml,*.yaml,*.yml.tpl,*.yaml.tpl call YAMLWhitespace()
"""

""" Filetype hcl
" HCLWhitespace sets tabs to 2 spaces.
function! HCLWhitespace()
	setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
endfunction
autocmd BufNewFile,BufRead *.hcl call HCLWhitespace()
"""

""" Filetype Makefile
" Do not reindent on colon.
autocmd FileType Makefile setlocal indentkeys-=<:>

""" Disable opening a help window on autocomplete.
set completeopt-=preview

""" Trim trailing whitespace before save.
autocmd FileType go,json,js,yaml,yml,bash,bats,hcl,py,c,cpp,java,php autocmd BufWritePre <buffer> %s/\s\+$//e
