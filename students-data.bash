main () {
	count_lines "$BOYS" "$GIRLS"
	eval "local str_list=($(filter_with_string "HRDM" "$BOYS" "$GIRLS"))"
	local hrdm_boys="${str_list[0]}"
	local hrdm_girls="${str_list[1]}"
	local hrdm="$(join_strings "$hrdm_boys" "$hrdm_girls")"
	local hrdm_reversed="$(join_strings "$hrdm_girls" "$hrdm_boys")"
	local hrdm_sorted="$(to_sorted_string "$hrdm")"
	count_lines "$hrdm_boys" "$hrdm_girls" "$hrdm" "${str_list[@]}"
	eval "local hrdm_line_list=($(to_line_list "$hrdm"))"
	are_equal_strings "$hrdm" "$hrdm_reversed" "$hrdm_sorted"
}

to_sorted_string () {
	local str="$1"
	local sorted_str="$(echo "$str" | sort)"
	echo "$sorted_str"
}

are_equal_strings () {
	local main_str="$1"; shift
	local str_list=("$@")
	eval "local main_line_list=($(to_line_list "$main_str"))"
	for str in "${str_list[@]}"; do	
		eval "local line_list=($(to_line_list "$str"))"
		local main_line_list_size="${#main_line_list[@]}"
		if (("${#line_list[@]}" != "$main_line_list_size" )); then
			return 1
		fi
		for i in $(seq 0 $((main_line_list_size))); do
			local word_list=(${line_list[i]})
			local main_word_list=(${main_line_list[i]})
			for word in "${word_list[@]}"; do
				local is_word_in_main_word_list=false
				for main_word in "${main_word_list[@]}"; do
					if [[ "$word" == "$main_word" ]]; then
						is_word_in_main_word_list=true	
					fi
				done
				if ! "$is_word_in_main_word_list"; then
					return
				fi				
			done
		done
	done
	return 0
}

to_line_list () {
	local str="$1"
	local -a line_list
	mapfile -t line_list < <(echo "$str")
	echo "${line_list[@]@Q}"
}

join_strings () {
	local str_list=("$@")
	local result_str=""
	for str in "${str_list[@]}"; do
		result_str="$(echo -e "$result_str\n$str")"
	done
	echo "$result_str"
}

filter_with_string () {
	local str_filter_list=($1); shift
	local str_list=("$@")
	for str_filter in "${str_filter_list[@]}"; do
		local filtered_str_list=()
		for str in "${str_list[@]}"; do
			filtered_str_list+=("$(
				echo "$str" |
				sed "/$str_filter/!d"
			)")
		done
		str_list=("${filtered_str_list[@]}")
	done
	echo "${str_list[@]@Q}"
}

count_lines () {
	local str_list=("$@")
	local result_list=()
	for str in "${str_list[@]}"; do
		result_list+=("$(echo "$str" | wc -l)")
	done
	echo "${result_list[@]}"
}

GIRLS=$(cat << "EOF"
Agravante, Kyla Christine BSBA-HRDM
Almoite, Kimberly J. BS-ENTREP
Apresto, Mary Angela BSBA-MM
Aquino, Myra S. BSBA-MM
Batcho, Apryl Ann BSIS
Billones, Reynalyn T. BSBA-MM
Boromeo, Renalyn BSBA-HRDM
Boquiren, Judy Ann M. BSBA-MM
Castro, Allesandra Nicol S. BSBA-HRDM
Catalan, Mary Grace Q. BS-ENTREP
Cristobal, Cristina A. BSBA-MM
Dacanay, Jamaica BS-ENTREP
Delos Santos, Ella May A. BSBA-HRDM
Emocling, Cristina BS-ENTREP
Esteves, Kryzell Ann D. BSIS
Estrada, Ahthy Ah Jaen G. BSBA-MM
Fabillon, Marielle J. BSBA-MM
Flores, Ralamae O. BSBA-MM
Gotangogan, Belena N. BSBA-HRDM
Jimenez, Romalyn A. BSBA-MM
Lim, Sainah Ystelle C. BSBA-HRDM
Marcelo, Arlyn P. BSBA-MM
Mendoza, Rhea Ann A. BSBA-MM
Nazareno, Arlyn Mae L. BSBA-MM
Novela, Ina C. BSBA-HRDM
Oficiar, Vina P. BSBA-MM
Rafanan, Kesha Mae G. BSBA-MM
Riola, Nicole D. BSBA-MM
Salinas, Jenny D. BSBA-MM
Soriano, Gianne Mae V. BSBA-MM
Tangalin, Darlyn Q. BSBA-MM
Veloria, Cindy D. BSBA-MM
EOF
)


BOYS=$(cat << "EOF" 
Acosta, Daryl BSBA-MM
Austria, Joshua A. BSBA-MM
Basanes, Jasper Recca M. BS-ENTREP
Calosa, Mark Justine V. BSBA-MM
Camara, Julius S. BSBA-HRDM
Carranza, Jeric R. BSBA-HRDM
Cortez, Jhon Anthony BSIS
Dela Cruz, Jasper BSIS
Dela Cruz, Reynald BSIS
De Lara, Jerrson BSIS
De Leon, Jeric BSIS
Estigoy, Justine Aaron L. BSBA-HRDM
Eugenio, John Michael BSIS
Fajardo, Kim Harry BS-ENTREP
Frialde, Mark Jerick A. BSBA-MM
Gamboa, John Rey BS-ENTREP
Maquellao, Ginuel M. BS-ENTREP
Mendoza, John Rowie I. BSBA-HRDM
Quines, Jan Vincent  BS-ENTREP
Saliganan, Jasfer R. BSBA-HRDM
EOF
)

main
