main () {
	{
		local pdfPath="$1"
		local pdfSize
		pdfSize=$(pdfinfo "$pdfPath" | awk '/Pages:/ {print $2}')
	}
	{
		for pdfPage in $(seq 1 "$pdfSize"); do
			echo -en "[$pdfPage/$pdfSize] converting..."
			pdftoppm "$pdfPath" \
				-png \
				-r 300 \
				-singlefile \
				-f "$pdfPage" \
				"$pdfPath-$pdfPage"
			echo -en "Done.\n"
		done
	}
}

main "$@"
