#!/bin/bsh

main () {
	force_coc_install "$1"
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
	waitFor 2
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

main "$@"
