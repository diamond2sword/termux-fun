#!/bin/bash
main () {
	#reset neovim
	yes | {
		rm -rf ~/.local/share/nvim
		rm -rf ~/.config/nvim
		rm -rf ~/.config/coc
		apt-get purge neovim
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
		sh -c 'curl -fLo ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
		apt install fzf
       	apt install tree
       	apt install shellcheck
		apt install nodejs
		apt install git
	}

	mkdir -p ~/.config/nvim/lua/lsp
	mkdir -p ~/.config/nvim/after/syntax/sh
	echo "$INIT_VIM" > ~/.config/nvim/init.vim
	echo "$INIT_LUA" > ~/.config/nvim/lua/lsp/init.lua
	echo "$VIM_SH_HEREDOC_HIGHLIGHTING" > ~/.config/nvim/after/syntax/sh/heredoc-sh.vim
	
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
			extensions=("coc-json" "coc-git" "coc-sh")
			for extension in "${extensions[@]}"; do
				do_coc_install "$extension"
			done
			nvim +'PlugClean --sync' +qa
		}
	}

	echo "$COC_CONFIG" > ~/.config/nvim/coc-settings.json
	echo "$ZSH_PLUGINS_TXT" > ~/.zsh_plugins.txt
	echo "$ZSHRC_CUSTOM" > ~/.zshrc_custom

	yes | (
		#kotlin lsp
		apt install bat
		apt install unzip
		if [ -f ~/lsp/kotlin/server/bin/kotlin-language-server ]; then
			#escape downloading if kotlin lsp exists
			exit
		fi
		curl -LJO https://github.com/fwcd/kotlin-language-server/releases/download/1.3.7/server.zip
		unzip server.zip
		rm -rf ~/lsp
		mkdir -p ~/lsp/kotlin
		cp -rf server ~/lsp/kotlin
		rm -rf server server.zip
	)
	 
	#gradle
	yes | {
		apt install gradle
  	}

   	mkdir -p ~/.gradle/init.d
	echo "$OFFLINE_INIT_GRADLE_KTS" > ~/.gradle/init.d/offline.init.gradle.kts
	echo "$OPTIMIZE_INIT_GRADLE_KTS" > ~/.gradle/init.d/optimize.init.gradle.kts

	{
		(
			#git
			if [ -d ~/termux-fun ]; then
				#exit if repo termux-fun exists
				exit
			fi
			git clone https://www.github.com/diamond2sword/termux-fun
			cp -rf ~/termux-fun/project ~/termux-fun/install-setup.bash "$HOME"
			apt install openssh
		)

		(
			#gradle needs internet
			cd project || exit
			gradle --stop
			gradle clean build \
				--refresh-dependencies \
				--build-cache \
				-Dorg.gradle.jvmargs="-Xmx2g" \
				-PmustSkipCacheToRepo=false \
				-PisVerboseCacheToRepo=false
		)
	}

	yes | {
		#termux JetBrainsMono font
		curl -LJO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
		unzip ~/JetBrainsMono-2.304.zip -d ~/font
		cp ~/font/fonts/ttf/JetBrainsMono-Regular.ttf ~/.termux/font.ttf
		rm JetBrainsMono-2.304.zip
		rm -rf ~/font
		termux-reload-settings
	}
	
	yes | {
		#zsh
		apt install zsh

		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"	
		git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"

		#because antidote has to install plugins for zsh
		chsh -s zsh
		sed -i '/\#ZSHRC_CUSTOM/d' ~/.zshrc
		echo 'source ~/.zshrc_custom #ZSHRC_CUSTOM' >> ~/.zshrc
		echo "sed -i '/\#FIRST_START/d' ~/.zshrc; source ~/.zshrc_first_start #FIRST_START" >> ~/.zshrc
		echo "$ZSHRC_FIRST_START" > ~/.zshrc_first_start
	}

	yes | {
		#misc
		apt install file shfmt
		apt install imagemagick pandoc pdf2svg pdftk qpdf

		#study
		git-bash clone study

		#coding stuffs
		{
			# c++
			git-bash clone cpp-fun
			apt install clang
		}
		{
			# assembly
			git-bash clone asm-fun
			apt install binutils
		}
		git-bash clone c-fun
		git-bash clone bash-fun
		git-bash clone audio-shop
	}
}

git-bash () {
	bash $HOME/termux-fun/git.bash "$@"
}

do_coc_install () {
COC_EXTENSION=$1 expect <<- "EOF"
	set timeout -1
	set cocExtension $env(COC_EXTENSION)
	spawn nvim
	send ":CocInstall $cocExtension\r"
	expect_before -re "Installi" {
		send ":wincmd w|q\r"
		expect_before -re "Move|e ext|finished" {
			send ":q\r"
		}
		expect eof
	}
	expect eof
EOF
}

INIT_LUA=$(cat << "LUAEOF"

LUAEOF
)

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

let g:lightline = {
  \   'active': {
  \     'left': [[  'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok' ], [ 'coc_status'  ]]
  \   }
  \ }
" register components:
call lightline#coc#register()

EOF
)

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

EOF
)

VIM_SH_HEREDOC_HIGHLIGHTING=$(cat << 'VIMEOF'
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
VIMEOF
)


ZSHRC_CUSTOM=$(cat << "BASHEOF"
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
BASHEOF
)
ZSHRC_FIRST_START=$(cat << "BASHEOF"
#https://github.com/andrewferrier/fzf-z#pre-requisites
export FZFZ_SCRIPT_PATH=~/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z
mkdir -p $FZFZ_SCRIPT_PATH
curl https://raw.githubusercontent.com/rupa/z/master/z.sh > "$FZFZ_SCRIPT_PATH/z.sh"
exit
BASHEOF
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

COC_CONFIG=$(cat << "JSONEOF"
{
	"coc.preferences.jvmHeapSize": 2048,
	"languageserveir": {
		"kotlin": {
		    "command": "~/lsp/kotlin/server/bin/kotlin-language-server",
			"args": ["-Xmx2g", "-J-Xmx2g"],
	    	"filetypes": ["kotlin"],
			"javaHome": "$JAVA_HOME",
      		"javaServerOptions": ["-Xmx2g"],
			"initializationOptions": {
		      	"storagePath": "~/lsp/kotlin/caches"
		   	}
		}
	}
}
JSONEOF
)

OPTIMIZE_INIT_GRADLE_KTS=$(cat << "KOTLINEOF"
fun main() {
}

main()
KOTLINEOF
)

OFFLINE_INIT_GRADLE_KTS=$(cat << "EOF"
fun main() {
	addLocalRepo()
	configureCacheToRepoTask()
}

fun configureCacheToRepoTask() {
	allprojects {
		buildscript {
			fun cacheToRepoInteractive() {
				val mustSkipCacheToRepo: String? by project
				val isVerboseCacheToRepo: String? by project
				val mustSkip = mustSkipCacheToRepo?.toBooleanStrictOrNull()
				val isVerbose = isVerboseCacheToRepo?.toBooleanStrictOrNull()
				cacheToRepo(mustSkip, isVerbose)
			}
			taskGraph.whenReady {
				val userSpecifiedTasks = startParameter.taskNames
				val allTasks = taskGraph.getAllTasks()
				if (userSpecifiedTasks.isNotEmpty()) {
					val lastTask = allTasks.last()
					lastTask.doLast {
						cacheToRepoInteractive()	
					}
				}
			}
		}
	}
}

fun addLocalRepo() {
	val reposDir = gradle.getGradleUserHomeDir().resolve("repos")
	val repoDir = reposDir.resolve("m2")
	repoDir.mkdirs()
	val repos = reposDir.listFiles().toList()
	beforeSettings {
		pluginManagement.repositories.addRepos(listOf(repoDir))
	}
	allprojects {
		repositories.addRepos(repos)
		buildscript.repositories.addRepos(repos)
	}
}

fun RepositoryHandler.addRepos(repos: List<File>?) {
	maven {
		repos?.forEach { repo ->
			setUrl(repo.toURI())
		}
	}
	gradlePluginPortal()
	mavenCentral()
	google()
}


fun cacheToRepo(mustSkip: Boolean? = null, isVerboseParam: Boolean? = null) {
	fun askUser(question: String) : Boolean {
		println("$question (yes/no)")
		return readLine()?.equals("yes", ignoreCase = true) ?: false
	}
	if (mustSkip ?: askUser("Skip cacheToRepo()?")) return

	var isVerbose = isVerboseParam ?: false 
	fun printVerbose(string: String) = when (isVerbose) {
		true -> println(string)
		false -> Unit
	}
	isVerbose = isVerboseParam ?: askUser("must be verbose?")

	val excludedFiletypes = listOf(".module")
	val includedFiletypes = listOf(".jar", ".pom")

	val cacheDir = file("${gradle.gradleUserHomeDir}/caches/modules-2/files-2.1")
	val customRepoDir = file("${gradle.gradleUserHomeDir}/repos/m2")

	println("cacheToRepo task is called.")
	println("cacheDir: $cacheDir")
	println("customRepoDir: $customRepoDir")

	cacheDir.walkTopDown().forEach { file ->
		if (!file.isFile) {
			printVerbose("File: ${file.name} - It's not a file.")
			return@forEach
		}
		printVerbose("File: ${file.name} - It's a file.")
		
		excludedFiletypes.forEach loop2@ { filetype ->
			if (!file.name.endsWith(filetype)) return@loop2
			printVerbose("File: ${file.name} - Excluded Filetype: ${filetype}")
			return@forEach
		}
		
		var isFiletypeIncluded = false
		for (filetype in includedFiletypes) {
			if (!file.name.endsWith(filetype)) continue
			isFiletypeIncluded = true
			break
		}
		if (!isFiletypeIncluded) {
			printVerbose("File: ${file.name} - Not in Included Filetypes: ${includedFiletypes.toString()}")
			if (!askUser("Do you want to copy this file?")) return@forEach
		}

		val relativePath = file.relativeTo(cacheDir).path
		val pathComponents = relativePath.split('/')
		val longPath = pathComponents[0].replace(".", "/")
		val name = pathComponents[1]
		val version = pathComponents[2]

		printVerbose("\tRelative path: $relativePath")
		printVerbose("\tlongPath: $longPath")
		printVerbose("\tname: $name")
		printVerbose("\tversion: $version")
		while (true) {	
			try {
				copy {
					from(file)
					into(customRepoDir.toPath().resolve("$longPath/$name/$version"))
				}
				printVerbose("Successfully copied ${file.name}.")
				break
			} catch (e: Exception) {
				printVerbose("Failed to copy ${file.name}. Reason: ${e.message}")
				if (askUser("Skip copying this one?")) break
			}
		}
	}
}

main()
EOF
)

main "$@"

while true; do
	exit
done
