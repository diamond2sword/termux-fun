#!/bin/bash

# shellcheck disable=SC2207,SC2086,SC2001,SC2028,SC2034

main () {
	force_move_file_with_cmd "$1" "$2" "$3"
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

main "$@"
