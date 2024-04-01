main () {
	set_clipboard_with "$1"
	echo "14" | is_listed_in "$(cat "$HOME/slides.txt" | list_to_line)"
}

set_clipboard_with () {
	{
		local str_list_file="$1"
		local str_list=()
		local str_list_file_line_count
		str_list_file_line_count=$(
			cat "$str_list_file" | wc -l
		)
	}
	{
		local file_line
		local cur_str=""
		local cur_str_index=0
		for file_line_num in $(seq 1 "$str_list_file_line_count"); do
			file_line=$(cat "$str_list_file" | get_line "$file_line_num")
			if (echo "$file_line" | is_indented | not | value && echo "$file_line" | is_empty | not | value); then
				str_list[$cur_str_index]="$cur_str"
				cur_str=""
				((cur_str_index++))
			else
				cur_str=$(
					echo "$cur_str"
					echo "$file_line"
				)
			fi
		done
	}
	{
		local response
		for str in "${str_list[@]}"; do
			str=$(echo "$str" | trim)
			echo -e "\t$str" | bat -p -l text | fmt -w "$(tput cols)"
			while true; do
				echo "$cur_str" | bat -p -l text | termux-clipboard-set
				echo -n "Copied! Copy again?[y]: "
				read -r response 
				echo "$response" | is_listed_in "y yes" | not | value && {
					break
				}
			done
		done
	}
}

value () {
	sed -n "/0/q0;q1"
}

trim () {
	trim_leading | trim_trailing
}

trim_leading () {
	local str
	str=$(get_piped_str)

	while true; do
		if (echo "$str" | get_line '1' | is_empty | not | value); then
			break
		fi
		if (echo "$str" | is_empty | value); then
			break
		fi
		str=$(echo "$str" | sed '1d')
	done
	
	echo "$str" | sed '1s/^\s*//'
}

trim_trailing () {
	local str
	str=$(get_piped_str)

	while true; do
		if (echo "$str" | get_line '$' | is_empty | not | value); then
			break
		fi
		if (echo "$str" | is_empty | value); then
			break
		fi
		str=$(echo "$str" | sed '$d')
	done

	echo "$str" | sed '$s/\s*$//'
}



is_listed_in () {
	local str
	str=$(get_piped_str)

	echo "$1" | has "$str"
}

is_in () {
	local str
	str=$(get_piped_str)
	
	echo "$1" | contains "$str"
}

has () {
	local str
	str=$(get_piped_str)

	local str_line_count
	str_line_count=$(echo "$str" | wc -l)
	echo "$str" | if ((str_line_count <= 1)); then
		 line_to_list
	fi | contains "^$1$"
}

is_indented () {
	contains "^\t" 
}

contains () {
	filter "$1" | is_empty | not	
}

filter () {
	sed -En "/$1/p"
}

get_line () {
	sed -n "$1p"
}

not () {
	sed -n "/0/q1;q0"
	echo "$?"
}

is_empty () {
	list_to_line | sed -En "/^\s*$/q0;q1"
	echo "$?"
}

list_to_line () {
	tr '\n' ' ' | sed -E "s/\s+/ /g"
}

line_to_list () {
	sed -E "s/\s+/ /g" | tr ' ' '\n'
}

line_count () {
	wc -l
}

get_piped_str () {
	while IFS= read -r str_line; do
		echo "$str_line"
	done
}

main "$@"
