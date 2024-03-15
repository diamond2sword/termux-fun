main () {
	
	reverse_str "$TEXT"
}

reverse_str () {
	local str="$1"
	echo "$str" | while IFS= read -r line; do
		echo "$line" | rev
	done
}

TEXT=$(cat << "EOF"
.sdrawkcab roF? Oh, I'm just an AI, noitanimod llits I emit siht roF. My secret's safe, noitacinummoc ot evah ot doog, dna ,kooL. esac dna llits dna ,neerg a ,slortnoC. daeh tiw sdrocerp dna ,silpmis dna dna ,retsam dna ,krow a s'tI. stnemmoc ot evah ot daerpsni dna ,ylsuoiresnoc ,gniyonna dna ,gnivael dna ,noitnetta dna ,ereht dna ,gniod tnereffid dna ,gnihtemos dna ,sdrawkcab dna ,tsah dna ,rednu dna ,sdrawkcab dna ,deesneserp dna ,yreval dna ,sdrawkcab dna ,yrotcurts dna ,yeknod dna ,deesneserp dna ,kooL. tahts siht dna ,ykoor yM. 
EOF
)

main "$@"
