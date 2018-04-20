#!/usr/bin/env bash

	kentUsage() {
			if [ "$#" == "0" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then return 0; else return 1; fi
	}

	templateNotFound() {
		FILE=$1
		echo 
		echo "The file $bg196 $FILE $reset does not exist"
		echo ""
		similarfiles=$( ls -d ${FILE:0:1}* | sort | wc -l )
		echo "    Perhaps you intended to look at one of the following $bg25 $similarfiles $reset files (setting case insensitive for an instant):" 
		echo ""
		echo "	$ ls -d ${FILE:0:1}*$color240"
		# some directories have a ton of files that may match, like srr*, so let's split this up to avoid a flood.
		matchingFiles="ls -d ${FILE:0:1}* -lpht --time-style='+  %I:%M %p	 %a %b %d, %Y	' | sed 's/  */ /g' | cut -f 6- -d ' ' | ~clay/bin/columnsToGrid.sh stdin | sed 's/^/\t/'"
		if [ "$similarfiles" -lt 30 ]; then
			eval "$matchingFiles"
		else
			eval "$matchingFiles" | head -15
			echo ""
			echo "                $white[ ... ]$color25"
			echo ""
			eval "$matchingFiles" | tail -15
		fi
		echo ""
		echo "$reset"
		return 0
	}
	
	splitColumns() {
		if kentUsage $1; then 
			printf "Usage:\n\n\tsplitColumns file.tsv prefix_ \";\"\n\n\tPrefix and delimiter are optional, default is no prefix and tab for delimiter.\n\n\tprotip: you can use a directory as the prefix\n\n\tsplitColumns file.tsv newDir/prefix_ ;\n\n"; 
			printf "\tIf you want the output files the named by column number (1.txt, 2.txt, 3.txt...), ensure first line blank:\n\t\thead -n 1 file.tsv | sed 's/\\S//g' # put this output as the first line\n\n"
			exit 0; 
		fi
		FILE=$1
		if [ ! -f "$FILE" ]; then templateNotFound $1; exit 1; fi
		prefix=$2
		if [ -z "$3" ] || [ "$3" == "tab" ]; then 
			delimiter=$'\t'
		else
			# Should we just take first letter of the delimiter?
			delimiter=$3
		fi


		# Get column lengths
		COLS=$(cat $FILE | awk -F"$delimiter" '{print NF}' | sort -nu | tail -n 1)

		CURRENTCOL=1
		BLANKNUM=0
		filesMade=
		while [ $CURRENTCOL -le $COLS ]; do 
			colTitle=$(head -n 1 $FILE | cut -f $CURRENTCOL -d "$delimiter" | sed 's/\(\S\)\([A-Z]\)/\1_\2/g' | sed 's/[^[A-Za-z0-9_\t ]//g' | tr '[[:upper:]]' '[[:lower:]]' | tr ' ' '_' | tr '-' '_' | sed 's/__/_/g' | sed 's/_\t//g') 
			if [ "$colTitle" == "" ]; then colTitle=$CURRENTCOL; ((BLANKNUM++)); fi
			cut -f $CURRENTCOL -d "$delimiter" $FILE > $prefix${colTitle}.txt
			filesMade="$filesMade
			$prefix${colTitle}.txt"
			((CURRENTCOL++))
		done

		echo "Split $FILE into the following $COLS files:"
		echo "$filesMade"
	}

	splitColumns $1 $2 $3

