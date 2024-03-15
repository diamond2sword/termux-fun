#!/bin/bash

main () {
	{
		#declarations
		local inputPDF="$1"
		local outDir="$HOME/output-pdf"
		local pageDir="$outDir/page-files"
		local pdfSize
		pdfSize=$(pdfinfo "$inputPDF" | awk '/Pages:/ {print $2}')
		local pdfSizeDigitCount=${#pdfSize}
		local pagePrefix="pdfpage"
		local modifierPrefix="-trimmed-"
		local pptMdStructStr=""
	}
	{
		#convert each page to png image
		for pageIndex in $(seq 1 "$pdfSize"); do
			#for this page:
			echo -e "page $pageIndex of $pdfSize:"
			local pageIndexWithFixedDigitCount > /dev/null
			pageIndexWithFixedDigitCount=$(printf "%0${pdfSizeDigitCount}d" "$pageIndex")
			{
				#listing image to ppt structure and template
				echo -e "\tlisting image to ppt structure and template..."

				pptMdStructStr=$(
					if ((pageIndex != 1)); then
						echo "$pptMdStructStr"
						echo
					fi
					echo "![]($pageDir/$pagePrefix$modifierPrefix$pageIndexWithFixedDigitCount.png)"
					echo
					if ((pageIndex != pdfSize)); then
						echo ---
						echo
					fi
				)
			}
		done
	}
	{
		#deleting old output ppt
		echo -e "deleting old output pptx..."
		rm "$outDir/output.pptx"
	}
	{
		#use pandoc to compile images by following a string structure
		echo -e "compiling images to pptx..."
		echo "$pptMdStructStr" > "$outDir/ppt-structure.md"
		local aspectRatio
		pageIndexWithFixedDigitCount=$(printf "%0${pdfSizeDigitCount}d" "$pageIndex")
		aspectRatio=$(identify -format "%w/%h" "$pageDir/$pagePrefix$modifierPrefix$pageIndexWithFixedDigitCount.png")
		pandoc -t pptx "$outDir/ppt-structure.md" \
			--slide-level 2 \
			-V aspectratio="$aspectRatio" \
			-o "$outDir/output.pptx"
	}
}

main "$@"
