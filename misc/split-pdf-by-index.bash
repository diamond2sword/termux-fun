main () {
	local inputPdf="$1"; shift
	local indexes=("$@")
	{
		local outDir="$HOME/output-pdf"
		local prefix="pdf-split"
		local indexes_size=${#indexes[@]}
	}
	{
		rm -rf "$outDir"
		mkdir -p "$outDir"
	}
	{
		for i in $(seq 0 $((indexes_size - 1))); do
			local curIndex="${indexes[$i]}"
			echo "getting pdf $i: indexed ($curIndex)..."
			eval $(echo "pdftk $inputPdf cat $curIndex output $outDir/$prefix-$i.pdf")
		done
	}
}



main "$@"
