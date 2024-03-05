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
		local pptMdStructStr=""
	}

	test_converter && {
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
			test_converter && {
				#extracting image of this page
				echo -e "\textracting image..."
				pdftoppm "$inputPDF" \
					-png \
					-singlefile \
					-f "$pageIndex" \
					-r "$ppmRes" \
					"$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount"
			}
			test_converter && {
				#trim white spaces
				echo -e "\tcropping image..."
				local trimmedPicWidth=3505
				local trimmedPicHeight=1972
				convert -crop ${trimmedPicWidth}x${trimmedPicHeight}+0+0 \
					"$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount.png" \
					"$pageDir/$pagePrefix-resized-$pageIndexWithFixedDigitCount.png"
			}
			{
				#listing image to ppt structure and template
				echo -e "\tlisting image to ppt structure and template..."

				pptMdStructStr=$(
					if ((pageIndex != 1)); then
						echo "$pptMdStructStr"
						echo
					fi
					echo "![]($pageDir/$pagePrefix-resized-$pageIndexWithFixedDigitCount.png)"
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
		echo -e "compiling cropped images to pptx..."
		echo "$pptMdStructStr" > "$outDir/ppt-structure.md"
		pandoc -t pptx "$outDir/ppt-structure.md" \
			--slide-level 2 \
			-V aspectratio="$trimmedPicWidth/$trimmedPicHeight" \
			-o "$outDir/output.pptx"
	}
}

test_converter () {
	return 1
}

main "$@"
