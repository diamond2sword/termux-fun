#!/bin/bash

main() { 
	yes | {
		apt update
		apt upgrade
		apt update

		#man pages
		apt install man

		#termux-api
		apt install termux-api
	 
		#vim
		apt install vim
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		apt install fzf
		apt install nodejs
		apt install git
		echo "$VIMRC" > ~/.vimrc
		vi +'PlugInstall --sync' +'PlugClean' +qa
		vi +'CocInstall -sync coc-git coc-sh' +qa
		apt install bat
		#kotlin lsp
		echo "$COC_CONFIG" > ~/.vim/coc-settings.json
		apt install unzip
		curl -LJO https://github.com/fwcd/kotlin-language-server/releases/download/1.3.6/server.zip
		unzip server.zip
		mkdir -p ~/lsp/kotlin
		cp -rf server ~/lsp/kotlin
		rm -rf server server.zip
	 
		#zsh
		apt install zsh
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"	
		git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
		echo "$ZSH_PLUGINS_TXT" > ~/.zsh_plugins.txt
		echo "$ZSHRC_CUSTOM" > ~/.zshrc_custom
		sed -i '/\#ZSHRC_CUSTOM/d' ~/.zshrc
		echo 'source ~/.zshrc_custom #ZSHRC_CUSTOM' >> ~/.zshrc	

	 
		#gradle
		apt install gradle

		#git
		git clone https://www.github.com/diamond2sword/termux-fun
		cp -rf ~/termux-fun/project ~/termux-fun/install-setup.bash $HOME
		apt install expect
		apt install openssh

		#gradle needs internet
		cd project
		gradle run --offline
	}

	#because antidote has to install plugins for zsh
	chsh -s zsh
	echo "sed -i '/\#FIRST_START/d' ~/.zshrc; exit #FIRST_START" >> ~/.zshrc
	zsh

	#https://github.com/andrewferrier/fzf-z#pre-requisites
	export FZFZ_SCRIPT_PATH=~/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z
	mkdir -p $FZFZ_SCRIPT_PATH
	curl https://raw.githubusercontent.com/rupa/z/master/z.sh > "$FZFZ_SCRIPT_PATH/z.sh"

	#termux JetBrainsMono font
	curl -LJO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
	unzip ~/JetBrainsMono-2.304.zip -d ~/font
	cp ~/font/fonts/ttf/JetBrainsMono-Regular.ttf ~/.termux/font.ttf
	rm JetBrainsMono-2.304.zip
	rm -rf ~/font
	termux-reload-settings
}

VIMRC=$(cat << "EOF"
call plug#begin()
Plug 'morhetz/gruvbox' "https://github.com/neoclide/coc.nvim/issues/3784
Plug 'udalov/kotlin-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'josa42/vim-lightline-coc'
Plug 'itchyny/lightline.vim'
call plug#end()

"https://linuxhandbook.com/vim-indentation-tab-spaces/
set autoindent
set noexpandtab
set tabstop=4 
set shiftwidth=4

"https://www.reddit.com/r/neovim/comments/131urrq/make_the_cursorline_in_neovim_semitransparent/
nmap <C-g> :Files<CR>

"https://github.com/neoclide/coc.nvim/issues/3784
set t_Co=256
syntax enable
silent! colorscheme gruvbox
autocmd ColorScheme * highlight CocHighlightText gui=None guibg=#665c54
set background=dark
let g:coc_default_semantic_highlight_groups = 1

"https://jeffkreeftmeijer.com/vim-number/
set number
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
	autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

"https://www.reddit.com/r/vim/comments/eck1tl/comment/fbcox26/
set cursorline

"https://github.com/neoclide/coc.nvim#example-vim-configuration
set encoding=utf-8
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-b>"
nnoremap <silent><nowait><expr> <C-v> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-v>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-v> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-b>"
vnoremap <silent><nowait><expr> <C-v> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-v>"

let g:lightline = {
  \   'active': {
  \     'left': [[  'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok' ], [ 'coc_status'  ]]
  \   }
  \ }

" register compoments:
call lightline#coc#register()
EOF
)


ZSHRC_CUSTOM=$(cat << "EOF"
#https://getantidote.github.io/install
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins.zsh
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt
fpath+=(${ZDOTDIR:-~}/.antidote)
autoload -Uz $fpath[-1]/antidote
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
  (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
fi
source $zsh_plugins

#https://github.com/agkozak/zsh-z#general-observations
autoload -U compinit; compinit
zstyle ':completion:*' menu select

#https://github.com/catppuccin/bat#usage
export BAT_THEME=gruvbox-dark

#https://github.com/andrewferrier/fzf-z#customizing-and-options
export FZFZ_EXTRA_OPTS=" --border=sharp --preview-window=border-sharp"
export FZFZ_SUBDIR_LIMIT=0
EOF
)

ZSH_PLUGINS_TXT=$(cat << "EOF"
zsh-users/zsh-autosuggestions

rupa/z
agkozak/zsh-z

ohmyzsh/ohmyzsh path:plugins/fzf
ohmyzsh/ohmyzsh path:plugins/git

andrewferrier/fzf-z
EOF
)

COC_CONFIG=$(cat << "EOF"
{
	"languageserver": {
	  "kotlin": {
	    "command": "~/lsp/kotlin/server/bin/kotlin-language-server",
	    "filetypes": ["kotlin"]
	  }
	}
}
EOF
)

main "$@"
exit
