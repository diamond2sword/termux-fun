#!/bin/bash

main() { 
	yes | {
		apt update
		apt upgrade
#		apt update
#
#
#		#man pages
#		apt install man
#
#		#termux-api
#		apt install termux-api
#	 
#		#neovim
		apt install neovim
		sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
#		apt install fzf
#       apt install tree
#		apt install nodejs
#		apt install git
	}

	mkdir -p ~/.config/nvim/lua/lsp
	echo "$INIT_VIM" > ~/.config/nvim/init.vim
	echo "$INIT_LUA" > ~/.config/nvim/lua/lsp/init.lua
#	nvim +'PlugInstall --sync' +qa
#	nvim +'PlugClean --sync' +qa
#	#Non-interactive CocInstall with display using Expect
#	yes | { 
#		apt install expect
#	}
#	extensions=("coc-json" "coc-git" "coc-sh")
#	for extension in "${extensions[@]}"; do
#		do_coc_install $extension
#	done
#	nvim +'PlugClean --sync' +qa

	yes | {
#		apt install bat
#		#kotlin lsp
		echo "$COC_CONFIG" > ~/.vim/coc-settings.json
#		apt install unzip
#		curl -LJO https://github.com/fwcd/kotlin-language-server/releases/download/1.3.7/server.zip
#		unzip server.zip
#		rm -rf ~/lsp
#		mkdir -p ~/lsp/kotlin
#		cp -rf server ~/lsp/kotlin
#		rm -rf server server.zip
#	 
#		#zsh
#		apt install zsh
#		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"	
#		git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
		echo "$ZSH_PLUGINS_TXT" > ~/.zsh_plugins.txt
		echo "$ZSHRC_CUSTOM" > ~/.zshrc_custom
		sed -i '/\#ZSHRC_CUSTOM/d' ~/.zshrc
		echo 'source ~/.zshrc_custom #ZSHRC_CUSTOM' >> ~/.zshrc 
#
#		#git
#		git clone https://www.github.com/diamond2sword/termux-fun
#		cp -rf ~/termux-fun/project ~/termux-fun/install-setup.bash $HOME
#		apt install openssh
	
		
	}

	#gradle
	apt install gradle
	echo "$OFFLINE_INIT_GRADLE_KTS" > ~/.gradle/init.d/offline.init.gradle.kts
	echo "$OPTIMIZE_INIT_GRADLE_KTS" > ~/.gradle/init.d/optimize.init.gradle.kts
	(
		#gradle needs internet
		cd project
		./gradlew --stop
		./gradlew clean build \
			--refresh-dependencies \
			--build-cache \
			-Dorg.gradle.jvmargs="-Xmx2g" \
			-PmustSkipCacheToRepo=false \
			-PisVerboseCacheToRepo=false
	)

#	#because antidote has to install plugins for zsh
#	chsh -s zsh
#	echo "sed -i '/\#FIRST_START/d' ~/.zshrc; exit #FIRST_START" >> ~/.zshrc
#	zsh

#	yes | {
#		#https://github.com/andrewferrier/fzf-z#pre-requisites
#		export FZFZ_SCRIPT_PATH=~/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z
#		mkdir -p $FZFZ_SCRIPT_PATH
#		curl https://raw.githubusercontent.com/rupa/z/master/z.sh > "$FZFZ_SCRIPT_PATH/z.sh"
#
#		#termux JetBrainsMono font
#		curl -LJO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
#		unzip ~/JetBrainsMono-2.304.zip -d ~/font
#		cp ~/font/fonts/ttf/JetBrainsMono-Regular.ttf ~/.termux/font.ttf
#		rm JetBrainsMono-2.304.zip
#		rm -rf ~/font
#		termux-reload-settings
#	}
}

do_coc_install () {
COC_EXTENSION=$1 expect <<- "EOF"
	set timeout -1
	set cocExtension $env(COC_EXTENSION)
	spawn nvim
	send ":CocInstall $cocExtension\r"

	expect_before -re "Move extension" {
		exec sleep 1
		send "qa!\r"
	}
	expect eof
EOF
}

INIT_LUA=$(cat << "EOF"

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
	return !col || getline('.')[col - 1]	=~# '\s'
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

#neovim alias
alias vim='nvim'
alias vi='vim'
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

OPTIMIZE_INIT_GRADLE_KTS=$(cat << "EOF"
fun main() {
}

main()
EOF
)

OFFLINE_INIT_GRADLE_KTS=$(cat << "EOF"
fun main() {
	addLocalRepo()
	allprojects {
		buildscript {
			plugins.apply("java")
			tasks.register("cacheToRepo") {
				doLast {
					val mustSkipCacheToRepo: String? by project
					val isVerboseCacheToRepo: String? by project
					val mustSkip = mustSkipCacheToRepo?.toBooleanStrictOrNull()
					val isVerbose = isVerboseCacheToRepo?.toBooleanStrictOrNull()
					cacheToRepo(mustSkip, isVerbose)
				}
			}
			afterEvaluate {
				val userSpecifiedTasks = gradle.startParameter.taskNames
				if (userSpecifiedTasks.isNotEmpty()) {
					val lastTask = userSpecifiedTasks.last()
					tasks.named(lastTask) {
						finalizedBy("cacheToRepo")
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
	mavenCentral()
	google()
	maven {
		repos?.forEach { repo ->
			setUrl(repo.toURI())
		}
	}
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
	val customRepoDir = file("${gradle.gradleUserHomeDir}/m2")

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
exit
