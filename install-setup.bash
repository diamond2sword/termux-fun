!/bin/bash

main () {
	{
		# setup github secret
  		local github_personal_token="$1"
		local ssh_key_passphrase="$2"
  		if [[ "$github_personal_token" == "" ]]; then
			echo -en "Github Personal Token:"
			read -r github_personal_token
   		fi
	 	if [[ "$ssh_key_passphrase" == "" ]]; then
			echo -en "SSH Key Passphrase:"
			read -r ssh_key_passphrase
   		fi
  		echo -n "$github_personal_token" > "$HOME/github-personal-token.txt"
		echo -n "$ssh_key_passphrase" > "$HOME/ssh-key-passphrase.txt"
	}
	yes | {
		apt update
		apt upgrade
		apt update

		#man pages
		apt install man

		#termux-api
		apt install termux-api
	 
		#neovim
		apt install neovim
		local plug_vim_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
		force_move_file_with_cmd f "$plug_vim_path" "curl -fLo '$plug_vim_path' --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' || rm -rf '$plug_vim_path'"
EOF
		apt install fzf
       	apt install tree
       	apt install shellcheck
		apt install nodejs
		apt install git
	}

	mkdir -p ~/.config/nvim/lua/lsp
	mkdir -p ~/.config/nvim/after/syntax/sh
	echo "$INIT_VIM" > ~/.config/nvim/init.vim
	echo -E "$VIM_SH_HEREDOC_HIGHLIGHTING" > ~/.config/nvim/after/syntax/sh/heredoc-sh.vim
	
	{
		{
			nvim +'PlugInstall --sync' +qa
			nvim +'PlugClean --sync' +qa
		}

		{
			#Non-interactive CocInstall with display using Expect
			yes | { 
				apt install expect
			}
			local coc_extension_list=(coc-json coc-git coc-sh coc-clangd coc-html coc-css coc-tsserver)
			for coc_extension in "${coc_extension_list[@]}"; do
				force_coc_install "$coc_extension"
			done
		}
	}

	echo "$COC_CONFIG" > ~/.config/nvim/coc-settings.json
	echo "$ZSH_PLUGINS_TXT" > ~/.zsh_plugins.txt
	echo "$ZSHRC_CUSTOM" > ~/.zshrc_custom

	yes | {
		#kotlin lsp
		apt install bat
		apt install unzip
#		kotlin_lsp_zip_url="https://github.com/fwcd/kotlin-language-server/releases/download/1.3.7/server.zip"
#		force_move_file_with_cmd f "$HOME/lsp/kotlin/server/bin/kotlin-language-server" <(cat << EOF
#			force_move_file_with_cmd f "$HOME/server.zip" "curl -LJ --create-dirs -O --output-dir '$HOME' '$kotlin_lsp_zip_url' || rm -rf '$HOME/server.zip'"
#			unzip "$HOME/server.zip"
#			rm -rf "$HOME/lsp/kotlin"
#			mkdir -p "$HOME/lsp/kotlin"
#			cp -rf "$HOME/server" "$HOME/lsp/kotlin"
#			rm -rf "$HOME/server"
#EOF
#		)
#		rm -rf "$HOME/server.zip"
	}
	 
	#gradle
	yes | {
		apt install gradle
  	}

	(
		#git
		force_move_file_with_cmd d "$HOME/termux-fun" "git clone 'https://github.com/diamond2sword/termux-fun' '$HOME/termux-fun' || rm -rf '$HOME/termux-fun'"
		git_bash_clone project	
		apt install openssh

		#gradle needs internet
		cd "$HOME/project"
		bash gradle.bash version
	)

	yes | {
		#termux JetBrainsMono font
		local zip_name="JetBrainsMono-2.304.zip"
		local font_name="JetBrainsMono-Regular.ttf"
		local termux_dir="$HOME/.termux"

		force_move_file_with_cmd f "$termux_dir/$font_name" <(cat <<- EOF
			force_move_file_with_cmd f "$HOME/$zip_name" "curl -LJO --create-dirs --output-dir '$HOME' 'https://download.jetbrains.com/fonts/$zip_name' || rm -rf '$termux_dir/$zip_name'"
			unzip '$HOME/$zip_name' -d "$HOME/font"
			cp "$HOME/font/fonts/ttf/$font_name" "$termux_dir"
			cp "$termux_dir/$font_name" "$termux_dir/font.ttf"
			rm -rf "$HOME/font"
			rm -rf "$HOME/$zip_name"
			termux-reload-settings
EOF
		)
	}
	
	yes | {
		#zsh
		apt install zsh

		{
			force_move_file_with_cmd d "$HOME/.oh-my-zsh" <(cat << EOF
				force_move_file_with_cmd f "$HOME/install.sh" "curl -LJO --create-dirs --output-dir '$HOME' 'https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh' || rm -rf '$HOME/install.sh'"
				sh -c "\$(cat "$HOME/install.sh")"
EOF
			)
			rm -rf "$HOME/install.sh"
		}
		local antidote_path="${ZDOTDIR:-$HOME}/.antidote"
		force_move_file_with_cmd d "$antidote_path" "git clone --depth=1 'https://github.com/mattmc3/antidote.git' '$antidote_path' || rm -rf '$antidote_path'"

		#because antidote has to install plugins for zsh
		chsh -s zsh
		sed -i '/\#ZSHRC_CUSTOM/d' ~/.zshrc
		echo 'source ~/.zshrc_custom #ZSHRC_CUSTOM' >> ~/.zshrc
		local FZFZ_SCRIPT_PATH="$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z"
		force_move_file_with_cmd f "$FZFZ_SCRIPT_PATH/z.sh" <(cat << EOF
			force_move_file_with_cmd f "$HOME/z.sh" "curl -LJO --create-dirs --output-dir '$HOME' 'https://raw.githubusercontent.com/rupa/z/master/z.sh' || rm -rf '$HOME/z.sh'"
			echo "sed -i '/\#FIRST_START/d' ~/.zshrc; source ~/.zshrc_first_start #FIRST_START" >> ~/.zshrc
			echo "$ZSHRC_FIRST_START" > ~/.zshrc_first_start
EOF
		)
	}

	yes | {
		#study
		git_bash_clone study
		git_bash_clone bash-fun
		git_bash_clone java-fun

		#coding stuffs
		{
			# c++, c
			git_bash_clone cpp-fun
			git_bash_clone c-fun
			apt install clang
		}
		{
			# assembly
			git_bash_clone asm-fun
			apt install binutils
		}
		{
			#github
			pkg install gh
		}
		{
			# python
			git_bash_clone python-fun
			apt install python
		}
		{
			# print
			git_bash_clone print-shop
			apt install file shfmt
			apt install imagemagick pandoc pdf2svg pdftk qpdf
		}
	}
}

git_bash_clone () {
	local repo_name="$1"
	local dst_file="$HOME/$repo_name"
	force_move_file_with_cmd d "$dst_file" "bash '$HOME/termux-fun/git.bash' clone '$repo_name' || rm -rf '$dst_file'"
}

force_move_file_with_cmd () {
	local file_type="$1"
	local dst_path="$2"
	local cmd="$3"
	local file_cmd
	eval_cmd () {
		echo "force_move_file_with_cmd: executing string: $cmd"
		eval "$cmd"
	}
	if (echo "$cmd" | sed -n "/\/proc\/self\/fd\//!q1"); then
		file_cmd="$(cat "$cmd")"
		eval_cmd () {
			echo "force_move_file_with_cmd: executing file: $cmd"
			echo -e "\n\n$(echo "$file_cmd" | with_common_indent 0)\n\n"
			eval "$file_cmd"
		}
	fi
	while true; do
		if [[ "$file_type" == "d" ]]; then
			if [ -d "$dst_path" ]; then
				return
			fi
		fi
		if [[ "$file_type" == "f" ]]; then
			if [ -f "$dst_path" ]; then
				return
			fi
		fi
		eval_cmd
		sleep 1
	done
}

with_common_indent () {
	local num_indents="$1"
	local str
	local str_tab_list
	str="$(cat)"
	str_tab_list=($(
		echo "$str" |
		sed -E 's/^(\t*).*/\1/g' |
		tr '\t' '-'
	))
	local least_num_indents=${#str_tab_list[1]}
	for str_tab in "${str_tab_list[@]}"; do
		least_num_indents=$(math_min ${#str_tab} $least_num_indents)
	done

	cur_common_indent=$(
		for i in $(seq 1 $least_num_indents); do
			echo -n '\t'
		done
	)

	new_common_indent=$(
		for i in $(seq 1 $num_indents); do
			echo -n '\t'
		done
	)

	echo "$str" |
		sed "s/^$cur_common_indent/$new_common_indent/g"
}

math_min () {
	local num1=$1
	local num2=$2
	if ((num1 < num2)); then
		echo $num1
	else
		echo $num2
	fi
}

force_coc_install () {
	local coc_extension="$1"
	echo "getting '$coc_extension'..."
	while (! is_coc_extension_installed "$coc_extension"); do
		coc_install "$coc_extension"
	done
}

coc_install () {
COC_EXTENSION="$1" \
expect  <<- "EOF"
	set cocExtension $env(COC_EXTENSION)

	proc main {} {
		set timeout -1
		
		global cocExtension
		spawn nvim 
		send ":CocInstall $cocExtension\r"

		expect -re "Installi"
		send ":wincmd w|q\r"

		expect -re "Move|e ext|finished|Error"
		return -level 1 code [expr {$expect_out(0,string) ne "Error" ? 0 : 1}]
	}

	main
EOF
}

is_coc_extension_installed () {
COC_EXTENSION="$1" \
expect <<- "EOF"
	proc removeHyphen {str} {
		return [string map [list {-} {}] $str]
	}

	proc waitFor {int} {
		set timeout $int
		expect {
			expect
			timeout {set timeout -1}
		}
	}

	set timeout -1
	set cocExtension $env(COC_EXTENSION)
	set cocExtensionClue [removeHyphen $cocExtension]

	spawn nvim
	expect {No mapping found}
	send ":CocList extensions\r"
	expect {FUZZY}
	expect {extensions}
	send "$cocExtensionClue"
	waitFor 1
	send "\t"
	expect {Choose}
	send {c}
	set timeout 1
	expect {
		-re {"[^"]*"} {
			set timeout 1
			send "gg"
			expect {
				$cocExtension {exit 0}
				timeout {exit 1}
			}
		}
		timeout {
			set timeout 1
			expect {
				{FUZZY} {exit 1}
				timeout {exit 0}
			}
		}
	}
EOF
}

INIT_VIM=$(cat << "EOF"
call plug#begin('~/.config/nvim/plugged')
Plug 'morhetz/gruvbox' "https://github.com/neoclide/coc.nvim/issues/3784
Plug 'sheerun/vim-polyglot'
Plug 'frazrepo/vim-rainbow'
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
verbose imap <tab>
lua << EOF2
-- https://github.com/neoclide/coc.nvim#example-vim-configuration
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 1000 
vim.opt.signcolumn = "yes"
local keyset = vim.keymap.set
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keyset("n", "gr", "<Plug>(coc-references)", {silent = true})
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
})
vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescript,json",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
})
vim.api.nvim_create_autocmd("User", {
    group = "CocGroup",
    pattern = "CocJumpPlaceholder",
    command = "call CocActionAsync('showSignatureHelp')",
    desc = "Update signature help on jump placeholder"
})
local opts = {silent = true, nowait = true, expr = true}
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-b>"', opts)
keyset("n", "<C-v>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-v>"', opts)
keyset("i", "<C-b>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-v>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-b>"', opts)
keyset("v", "<C-v>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-v>"', opts)
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
local opts = {silent = true, nowait = true}
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)
EOF2

let g:lightline = {
	\ 'active': {
  	\ 	'left': [['coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok'], ['coc_status']]
  	\ }
\ }

" register compoments:
call lightline#coc#register()


" copy paste
nnoremap <c-c> :call SetClipboardText()<CR>
nnoremap <c-v> :call GetClipboardText()<CR>
function! SetClipboardText()
	let l:yankedText = @"
	call system("(termux-clipboard-set <(cat \"EOF\"\n" . l:yankedText . "\nEOF\n); termux-toast \"Copied Yanked Text To Clipboard\") &> /dev/null &")
endfunction
function! GetClipboardText()
	let l:clipboardText = system("termux-clipboard-get; termux-toast \"Copied Clipboard Text To Yanked Register\"")
	let @" = l:clipboardText
endfunction


" fix wordwrap


" save vim or git keybind
nnoremap <c-s> :call Save()<CR>
function! Save()
	:wa
	call system("{ cd \"$(git rev-parse --show-toplevel)\"; bash git.bash push; termux-toast \"Git Pushed\";} &")
endfunction
EOF
)

VIM_SH_HEREDOC_HIGHLIGHTING=$(cat << "EOF"
function! Main()
	syntax cluster shHeredocHL contains=@sh

	let g:heredocStartPattern = '<<-\?\s*\(["\x27]\)\(\(\w\+\)EOF\)\1\s*'
	let g:previousDefinedHeredocFiletype = v:null
	let g:neededHeredocFiletypeList = ['sh', 'zsh', 'bash']

	for filetype in g:neededHeredocFiletypeList
		call DefineHeredocSyntaxRegionFor(filetype)
	endfor

	nnoremap G :call UpdateCursorHeredocSyntaxRegion()<CR>
endfunction

function! UpdateCursorHeredocSyntaxRegion()
	let [l:heredocStartRow, _] = searchpos(g:heredocStartPattern, 'zbnW')
	let l:heredocStartString = getline(l:heredocStartRow)
	let l:heredocStartMatchList = matchlist(l:heredocStartString, g:heredocStartPattern)
	if len(l:heredocStartMatchList) == 0
		return v:null
	endif
	let l:filetype = tolower(l:heredocStartMatchList[3])

	if count(g:neededHeredocFiletypeList, l:filetype) != 0
		return v:null
	endif

	if l:filetype == g:previousDefinedHeredocFiletype
		return v:null
	endif

	let l:syntaxPath = 'syntax/' . l:filetype . '.vim'
	if findfile(l:syntaxPath, &runtimepath) == ""
		return v:null
	endif
	
	if g:previousDefinedHeredocFiletype == v:null
		call DefineHeredocSyntaxRegionFor(l:filetype)
		let g:previousDefinedHeredocFiletype = l:filetype
		return v:null
	endif

	let l:previousRegion = 'heredoc' . g:previousDefinedHeredocFiletype
	if hlexists(l:previousRegion) 
		execute 'syntax clear ' . l:previousRegion
		let g:previousDefinedHeredocFiletype = v:null
		return v:null
	endif

	call DefineHeredocSyntaxRegionFor(l:filetype)
	let g:previousDefinedHeredocFiletype = l:filetype
endfunction

function! DefineHeredocSyntaxRegionFor(filetype)
	let l:bcs = b:current_syntax
	unlet b:current_syntax
	execute 'silent! syntax include @' . a:filetype . ' syntax/' . a:filetype . '.vim'
	let b:current_syntax = l:bcs

	let l:region = 'heredoc' . a:filetype
	let l:delimiter = toupper(a:filetype)
	let l:start_pattern = '/<<-\?\s*\([\x27"]\)' . l:delimiter . 'EOF\1\s*/'
	let l:end_pattern = '/^' . l:delimiter . 'EOF$/'
	execute 'syntax region ' . l:region . 
		\ ' matchgroup=Snip' .
		\ ' start=' . l:start_pattern . 
		\ ' end=' . l:end_pattern .
		\ ' containedin=@sh,@shHereDocHL contains=@' . a:filetype
	execute 'syntax cluster shHeredocHL add=' . l:region
endfunction

call Main()
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
export FZFZ_EXTRA_OPTS=" --border=sharp --preview-window=border-sharp --bind='ctrl-b:preview-down,ctrl-v:preview-up'"
export FZFZ_SUBDIR_LIMIT=0
export FZF_BIN_PATH="fzf --bind='ctrl-z:abort'"

#neovim alias
alias vim='nvim'
alias vi='vim'
EOF
)

ZSHRC_FIRST_START=$(cat << "EOF"
#https://github.com/andrewferrier/fzf-z#pre-requisites
export FZFZ_SCRIPT_PATH=~/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z
mv "$HOME/z.sh" "$FZFZ_SCRIPT_PATH/z.sh"
exit
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

#COC_CONFIG=$(cat << "EOF"
#{
#	"languageserver": {
#		"kotlin": {
#		    "command": "~/lsp/kotlin/server/bin/kotlin-language-server",
#			"args": ["-Xmx2g", "-J-Xmx2g"],
#	    	"filetypes": ["kotlin"],
#			"initializationOptions": {
#		      	"storagePath": "~/lsp/kotlin/caches"
#		   	}
#		}
#	}
#}
#EOF
#)

main "$@"

pid_list=($(ps -A | sed -E 's/^\s*([0-9]+).*/\1/g'))
for pid in "${pid_list[@]}"; do
	kill -9 "$pid"
done
exit
