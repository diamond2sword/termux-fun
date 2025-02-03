#!/bin/bash

# shellcheck disable=SC2034,SC2164,SC2207,SC2086,SC2028,SC2001,SC2317

main () {
	{
		#configure termux
		local termux_properties_path="$HOME/.termux/termux.properties"
		local termux_properties
		termux_properties=$(cat "$termux_properties_path")
		new_termux_properties="$({
			local is_custom=1
			echo "$termux_properties" | while read -r line; do
				if [[ "$line" =~ \#CUSTOM_PROPERTIES ]]; then
					is_custom=$((1 - is_custom))
					continue
				fi
				(exit "$is_custom") && {
					continue
				}
				echo "$line"
			done
			echo "#CUSTOM_PROPERTIES"
			echo "$TERMUX_PROPERTIES"
			echo "#CUSTOM_PROPERTIES"
		})"

		echo "$new_termux_properties" > "$termux_properties_path"
	}
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
		#basic start
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
		apt install fzf
       	apt install tree
       	apt install shellcheck
		apt install nodejs
			
		# markdown
		pkg install glow
		npm install -g markserv
		
		# bat
		apt install bat
		
		#openssh
		apt install openssh

		#github
		apt install git
		pkg install gh
	}
	
	#neovim and plugins
	{
		{
			#neovim init files
			mkdir -p ~/.config/nvim/lua/lsp
			mkdir -p ~/.config/nvim/after/syntax/sh
			echo "$INIT_VIM" > ~/.config/nvim/init.vim
			echo -E "$VIM_SH_HEREDOC_HIGHLIGHTING" > ~/.config/nvim/after/syntax/sh/heredoc-sh.vim

			#neovim plugins
			nvim +'PlugInstall --sync' +qa
			nvim +'PlugClean --sync' +qa
		}

		{
			#neovim plugins
			#Non-interactive CocInstall with display using Expect
			yes | { 
				apt install expect
			}
			local coc_extension_list=(coc-json coc-git coc-sh coc-clangd coc-html coc-css coc-tsserver coc-python coc-cmake)
			for coc_extension in "${coc_extension_list[@]}"; do
				force_coc_install "$coc_extension"
			done

			#configure coc.nvim
			echo "$COC_CONFIG" > ~/.config/nvim/coc-settings.json
		}
	}

	yes | {
		#termux repo
		force_move_file_with_cmd d "$HOME/termux-fun" "git clone 'https://github.com/diamond2sword/termux-fun' '$HOME/termux-fun' || rm -rf '$HOME/termux-fun'"

		#termux font JetBrainsMono
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

	#zsh
	yes | {
		#zsh
		apt install zsh

		{
			#oh-my-zsh
			force_move_file_with_cmd d "$HOME/.oh-my-zsh" <(cat << EOF
				force_move_file_with_cmd f "$HOME/install.sh" "curl -LJO --create-dirs --output-dir '$HOME' 'https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh' || rm -rf '$HOME/install.sh'"
				sh -c "\$(cat "$HOME/install.sh")"
EOF
			)
			rm -rf "$HOME/install.sh"
		}

		#because antidote has to install plugins for zsh
		local antidote_path="${ZDOTDIR:-$HOME}/.antidote"
		force_move_file_with_cmd d "$antidote_path" "git clone --depth=1 'https://github.com/mattmc3/antidote.git' '$antidote_path' || rm -rf '$antidote_path'"

		#fzfz
		local FZFZ_SCRIPT_PATH="$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-andrewferrier-SLASH-fzf-z"
		force_move_file_with_cmd f "$FZFZ_SCRIPT_PATH/z.sh" <(cat << EOF
			force_move_file_with_cmd f "$HOME/z.sh" "curl -LJO --create-dirs --output-dir '$HOME' 'https://raw.githubusercontent.com/rupa/z/master/z.sh' || rm -rf '$HOME/z.sh'"
			echo "sed -i '/\#FIRST_START/d' ~/.zshrc; source ~/.zshrc_first_start #FIRST_START" >> ~/.zshrc
			echo "$ZSHRC_FIRST_START" > ~/.zshrc_first_start
EOF
		)

		#configure zshrc for boot and installs
		echo "$ZSH_PLUGINS_TXT" > ~/.zsh_plugins.txt
		echo "$ZSHRC_CUSTOM" > ~/.zshrc_custom
		sed -i '/\#ZSHRC_CUSTOM/d' ~/.zshrc
		echo 'source ~/.zshrc_custom #ZSHRC_CUSTOM' >> ~/.zshrc
		chsh -s zsh
	}

	yes | {
		#study
		git_bash_clone study

#		git_bash_clone bash-fun
#		git_bash_clone java-fun

		#coding stuffs
#		{
#			# c++, c
#			apt install clang
#			pkg install cmake
#			git_bash_clone cpp-fun
#			git_bash_clone c-fun
#			npm install -g http-server
#			git_bash_clone clay-fun
#		}
#		{
#			# assembly
#			git_bash_clone asm-fun
#			apt install binutils
#		}
#		#kotlin with gradle
#		{
#			#gradle
#			yes | {
#				apt install gradle
#			}
#
#			(
#				#git
#				git_bash_clone project	
#
#				#kotlin project
#				cd "$HOME/project"
#				bash gradle.bash version
#			)
#		}

#		{
#			# python
#			git_bash_clone python-fun
#			apt install python
#			pip install mypy
#BUG			python -m pip install jedi
#			{
#				#pythondocx
#				pkg install tur-repo #for pandss?
#					
#				pkg install python-numpy
#				pkg install python-pandas
#				pip install pillow
#				{
#					#python docx
#					apt install clang
#					apt install libxml2
#					apt install libxslt
#					pip install cython
#					pkg install python-lxml
#					export CFLAGS="-Wno-incompatible-function-pointer-types -Wno-implicit-function-declaration"	pip install lxml
#					pip install python-docx
#				}
#				#pythondocx misc
#				pip install roman
#				pip install titlecase
#			}
#		}
#		{
#			# print
#			git_bash_clone print-shop
#			apt install file shfmt
#			apt install imagemagick pandoc pdf2svg pdftk qpdf
#		}
	}
}

git_bash_clone () {
	local repo_name="$1"
	local dst_file="$HOME/$repo_name"
	force_move_file_with_cmd d "$dst_file" "bash '$HOME/termux-fun/git.bash' clone '$repo_name' || rm -rf '$dst_file'"
}

force_move_file_with_cmd () {
	'./force_move_file_with_cmd.bash' "$@"
}

force_coc_install () {
	'./force_coc_install.bash' "$@"
}


INIT_VIM=$(cat './init.vim')
VIM_SH_HEREDOC_HIGHLIGHTING=$(cat './heredoc-sh.vim')
ZSHRC_CUSTOM=$(cat './zshrc_custom')
ZSHRC_FIRST_START=$(cat './zshrc_first_start')
ZSH_PLUGINS_TXT=$(cat './zsh_plugins.txt')
TERMUX_PROPERTIES=$(cat './termux.properties')

main "$@"

pid_list=($(ps -A | sed -E 's/^\s*([0-9]+).*/\1/g'))
for pid in "${pid_list[@]}"; do
	kill -9 "$pid"
done
exit
