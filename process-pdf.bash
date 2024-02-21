main () {
	false && {
		#dependency packages
		apt install qpdf pdftk pdf2svg
	}
	{
		#declarations
		local inputPDF="$1"
		local outDir="$HOME/output-pdf"
		local rotatedPDF="$outDir/rotated.pdf"
		local currentPDF="$outDir/current.pdf"
		local tempResultPDF="$outDir/tempResult.pdf"
		local resultPDF="$outDir/result.pdf"
		local pageDir="$outDir/page-files"
		local pagePrefix="pdfpage"
		local ppmRes=300
		local pdfSize
		pdfSize=$(pdfinfo "$inputPDF" | awk '/Pages:/ {print $2}')
		local pdfSizeDigitCount=${#pdfSize}
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
		#rotate pdf contents
		echo -e "rotating the contents of the pdf..."
		pdftk "$inputPDF" cat 1-endeast output "$rotatedPDF"
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
				pdftoppm "$rotatedPDF" \
					-png \
					-singlefile \
					-f "$pageIndex" \
					-r "$ppmRes" \
					"$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount"
			}
			{
				#split this image to halves
				echo -e "\tslicing image..."
				convert "$pageDir/$pagePrefix-extracted-$pageIndexWithFixedDigitCount.png" \
					-crop "50%x100%" \
					+repage \
					"$pageDir/$pagePrefix-half-$pageIndexWithFixedDigitCount-%d.png"
			}
			{
				pdfImageHalves=("$pageDir/$pagePrefix-half-$pageIndexWithFixedDigitCount"*)
				for pdfImageHalfIndex in 1 2; do
					#for this half:
					echo -e "\thalf $pdfImageHalfIndex of 2:"
					#convert it to pdf
					echo -e "\t\tconverting to pdf..."
					convert "${pdfImageHalves[pdfImageHalfIndex]}" -quality 100 -density 300 "$currentPDF"
					#combining result pdf and this pdf
					echo -e "\t\tcombining this pdf to the result pdf..."
					if [ ! -e "$resultPDF" ]; then
						echo -e "\t\tno result pdf: making this the result pdf..."
						mv "$currentPDF" "$resultPDF"
						continue
					fi
					pdftk "$resultPDF" "$currentPDF" cat output "$tempResultPDF"
					mv "$tempResultPDF" "$resultPDF"
				done
			}
		done
	}
}

main "$@"
