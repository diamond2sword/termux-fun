#!/bin/bash

main () {
	{
		#declarations
		local inputPDF="$1"
		local outDir="$HOME/output-pdf"
		local pageDir="$outDir/page-files"
		local ppmRes="300"
		local pdfSize
		pdfSize=$(pdfinfo "$inputPDF" | awk '/Pages:/ {print $2}')
		local pdfSizeDigitCount=${#pdfSize}
		local pagePrefix="pdfpage"
		local markdownString=""
	}

	{
		#create output folder
		if [ ! -e "$inputPDF" ]; then
			#file does not exists
			echo Error: file does not exist
			exit 1	
		fi
		if [ ! -f "$inputPDF" ]; then
			#file is not a regular file
			echo Error: file is not a regular file
			exit 1
		fi
		if [[ ! "$(file -b --mime-type "$inputPDF")" == "application/pdf" ]]; then
			#file is not a pdf file
			echo Error: file is not a pdf file
			exit 1
		fi
		if ! pdfinfo "$inputPDF" > /dev/null; then
			#pdf file is corrupt
			echo Error: pdf file is corrupt
			exit 1	
		fi
		rm -rf "$outDir"
		mkdir -p "$outDir" "$pageDir"
	}

	{
		#convert each page to png image
		for pageIndex in $(seq 1 "$pdfSize"); do
			#for this page:
			echo -e "page $pageIndex of $pdfSize:"
			local pageIndexWithFixedDigitCount > /dev/null
			pageIndexWithFixedDigitCount=$(printf "%0${pdfSizeDigitCount}d" "$pageIndex")
			{
				#extracting image of this page
				echo -e "\textracting image..."
				pdftoppm "$inputPDF" \
					-png \
					-singlefile \
					-f "$pageIndex" \
					-r "$ppmRes" \
					"$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount"
			}
			{
				#trim white spaces
				convert -trim \
					"$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount.png" \
					"$pageDir/$pagePrefix-trimmed-$pageIndexWithFixedDigitCount.png"
			}
		done
	}

}


main "$@"
