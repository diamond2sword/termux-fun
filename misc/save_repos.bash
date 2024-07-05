#!/bin/bash

main () {
	local gitbash_paths
	local repos
	gitbash_paths=$(find "$HOME"/**/git.bash)
	repo_paths=$(echo "$gitbash_paths" | while read -r gitbash_path; do
		echo "$gitbash_path" | dirname "$(cat)"
	done)
	echo "$repo_paths" | while read -r repo_path; do
		cd "$repo_path" || {
			echo "Info: Cannot CD to $repo_path"
			exit 1
		}
		echo -e "\nInfo: In $repo_path"
		./git.bash push
	done
}

main "$@"
