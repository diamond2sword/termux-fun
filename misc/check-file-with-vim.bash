main () {
	local filepath="$1"
	local delay=1
	if ! file_exists "$filepath"; then
		echo "folder doesn't exist: $filepath"
		echo -n "create file? (y/n): "
		read -n 1 answer
		if [ "$answer" != "y" ]; then
			return 1
		fi
		touch "$filepath"
	fi
	local current_file_time=$(get_file_time "$filepath")
	local check_count=1
	while true; do
		local previous_file_time="$current_file_time"
		sleep "$delay"
		current_file_time=$(get_file_time "$filepath")
		echo -en "\rcheck #$check_count"
		((check_count++))
		if is_equal "$current_file_time" "$previous_file_time"; then
			continue
		fi
		echo
		bat -p "$filepath"
	done
}

is_equal () {
	[ "$1" == "$2" ] && return 0
}

get_file_time () {
	stat -c %Y "$1"
}

file_exists () {
	[ -f "$1" ] && return 0
}

main "$@"
