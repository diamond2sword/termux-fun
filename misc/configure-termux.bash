#!/bin/bash

main () {
	#configure termux
	local termux_properties
	termux_properties=$(cat "$HOME/.termux/termux.properties")
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

	echo "$new_termux_properties"
}

TERMUX_PROPERTIES=$(cat << "EOF"
volume-keys = volume
extra-keys = [['','','','','','','KEYBOARD'],['ESC',{macro:"CTRL s",display:"PUSH"},{macro:"CTRL g",display:"FZFZ"},'HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF
)

main "$@"
