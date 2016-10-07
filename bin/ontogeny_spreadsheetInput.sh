#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_spreadsheetInput.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# Generates input for spreadsheets with metrics about tags, where it's easier to reconcile tags.

#################################################################################
# Usage
#################################################################################
# Just run the command. It will prompt you for the specifics.

#################################################################################
# Limitations
#################################################################################
#

################################################################################
# Config 
################################################################################

        #########################################################################
        # Color variables							#
        #########################################################################
	reset=`tput sgr0`
	off='\033[0m'
	white=`tput setaf 7`

	color114=$(echo -en "\e[38;5;114m") 
	color203=$(echo -en "\e[38;5;203m") 
	color207=$(echo -en "\e[38;5;207m") 
	color215=$(echo -en "\e[38;5;215m") 
	color240=$(echo -en "\e[38;5;240m") 
	color25=$(echo -en "\e[38;5;25m") 
	color81=$(echo -en "\e[38;5;81m") 
	bg25=$(echo -en "\e[48;5;25m") 

	#########################################################################
	# Set up gradients here to re-use.					#
	#########################################################################
		#########################################################################
		# Blue									#
		#########################################################################
		GRADIENT=$(for i in {16..21} ; do echo -en "\e[48;5;${i}m        " ; done ; )
		GRADIENTEND=$(for i in {21..16} ; do echo -en "\e[48;5;${i}m        \e[0m" ; done ;)
		#########################################################################
		# Gray									#
		#########################################################################
		GRADIENT2=$(for i in {232..249} ; do echo -en "\e[48;5;${i}m  " ; done ; )
		GRADIENT2END=$(for i in {249..232} ; do echo -en "\e[48;5;${i}m  \e[0m" ; done ;)
		#########################################################################
		# Red to yellow								#
		#########################################################################
		WARNINGGRADIENT=$(
	  		range2="220 214 208 202 196 196"
	  		range1="196 196 202 208 214 220"
        		printf "\n\n\t"; 
			for range in $range1; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m      "; i=$(( $i + 1 )); done; done;
			printf "          "
			for range in $range2; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m      "; i=$(( $i + 1 )); done; done; echo $reset;
		)

	line1="       ╔════════════════════════════════════════════════════════════════════════════════╗"
	line1m="       ╠════════════════════════════════════════════════════════════════════════════════╣"
	line1b="       ╚════════════════════════════════════════════════════════════════════════════════╝"
	line2="         ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	line3=""
	if [ "$1" == "" ]; then
		inputSelection=$(ls -t *meta* | head -n 1)
                if [ -s "$inputSelection" ]; then
                        printf ""
                else
                        inputSelection=""
                fi
		#inputSelection="meta.txt"
	else
		inputSelection=$1
	fi
	clear
	echo ""
	echo ""
	echo "$line1"
	echo "$color114         Tag Reconciliation Utility: generate input$color240 		github.com/claymfischer" 
	echo "$line2$reset"
	echo "	This wizard will guide you through the generation of a tag summary and statistics"
	echo "	file for use with the Tag Reconciliation Utility."
	echo "$color240"
	echo "	You may cancel by entering $bg25$white q! $reset$color240 at any part of the prompt."
	echo "$reset"
	echo "$line1m"
	echo ""
	#########################################################################
	# 			#
	#########################################################################
	echo -n "	Which file would you like to use for input? $color240			$color25"
	read -e -p "" -i "$inputSelection" inputFile
	printf $reset
	if echo $inputFile | grep -iq "q!"; then
		echo "	No problem, exiting now"
		echo ""
		exit 0
	fi
	if [ -s "$inputFile" ]; then
		numTags=$(cat $inputFile | sort -f -u -k1,1 | cut -d " " -f 1 | awk NF  | wc -l)
		numLines=$(cat $inputFile | wc -l | cut -f 1 -d " ")
		printf "	$color240$inputFile has $numTags uniqueTags and is $numLines lines$reset\n\n"
	else
		echo "	File does not exist. Exiting now."
		echo ""
		exit 0
	fi
	#########################################################################
	# 			#
	#########################################################################
	echo -n "	Would you like to use a prefix for the output files? $color240		$color25"
	read -e -p "" -i "reconcile_" inputPrefix
	echo $reset
	if echo $inputPrefix | grep -iq "q!"; then
		echo "$color240	No problem, exiting now$reset"
		echo ""
		exit 0
	fi
	#########################################################################
	# 			#
	#########################################################################
	echo -n "	How many lines would you like your input files to be? $color240(max 500)	$color25"
	read -e -p "" -i "200" inputLines
	echo $reset
	if echo $inputLines | grep -iq "q!"; then
		echo "	No problem, exiting now"
		echo ""
		exit 0
	fi
	#########################################################################
	# 			#
	#########################################################################
	if [ "$HOSTNAME" = "cirm-01" ]; then
		SERVER="cirm-01.pod"
	else
		SERVER="hgwdev.sdsc.edu"
	fi
	echo -n "	username for $SERVER? $color240					$color25"
	read -e -p "" -i "${USER}" inputAuth
	echo $reset
	if echo $inputAuth | grep -iq "q!"; then
		echo "	No problem, exiting now"
		echo ""
		exit 0
	fi
	#########################################################################
	# Can't have a trailing slash			 			#
	#########################################################################
	echo "	Path to$color25 $inputFile $color240(your current directory: $PWD)	$color25"
	echo -n "	"
	read -e -p "" -i "$PWD" inputPath
	echo $reset
	if echo $inputPath | grep -iq "q!"; then
		echo "	No problem, exiting now"
		echo ""
		exit 0
	fi
	#########################################################################
	# 			#
	#########################################################################
	echo "$line1m"
	echo ""
	echo "	Your input:"
	echo ""
	echo "	TagStorm to use as input: 		$color240$inputFile$reset"
	echo "	Prefix to use for temp files: 		$color240$inputPrefix$reset"
	echo "	Number of lines you'd like for input: 	$color240$inputLines$reset"
	echo "	SSH login to download files: 		$color240$inputAuth$reset"
	echo "	Path to $inputFile: 			$color240$inputPath$reset"
	echo ""
	echo -n "	Verify that this information is correct (y):	$bg25$white"
	read inputVerify
	echo $reset
	if echo $inputVerify | grep -iq "Y"; then
		echo "$line1m"
		echo ""
		# verify meta.txt or whatever their input was exists
		echo "	Generating files"
		#if files exist, prompt to overwrite
		echo $color240
		cd $inputPath
		echo "" > ${inputPrefix}column.txt #just a spacer

		# collapse a file to give accurate counts below... useful for files with 20,000 lines :)
		cat $inputFile | sed 's/\t//g' | awk NF | cut -d " " -f 1 > ${inputPrefix}collapsedTags.txt
		cat $inputFile | sed 's/\t//g' | awk NF | cut -d " " -f 2- > ${inputPrefix}collapsedMetadata.txt

		#################################################################
		# Input: collapsed tag storm					#
		#################################################################
		cat $inputFile | sed 's/\t//g' | head -$inputLines | cut -d " " -f 1  > ${inputPrefix}collapsedInput.txt; 		# To count tags
		cat $inputFile | sed 's/\t//g' | head -$inputLines | cut -d " " -f 2-  > ${inputPrefix}collapsedInputMetadata.txt;	# To count metadata
		paste -d' ' ${inputPrefix}collapsedInput.txt ${inputPrefix}collapsedInputMetadata.txt > ${inputPrefix}collapsed1.txt


		cat ${inputPrefix}collapsedInput.txt 		  | while read line; do if [[ "$line" =~ [^[:space:]] ]]; then grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedTags.txt; 	 else echo ""; fi | wc -l >> ${inputPrefix}collapsedInputCount.txt; done;
		cat ${inputPrefix}collapsedInputMetadata.txt	  | while read line; do if [[ "$line" =~ [^[:space:]] ]]; then grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedMetadata.txt ; else echo ""; fi | wc -l >> ${inputPrefix}collapsedInputMetadataCount.txt ; done;
		cat ${inputPrefix}collapsed1.txt | sed 's/\t/ /g' | while read line; do if [[ "$line" =~ [^[:space:]] ]]; then grep "^\([[:blank:]]*\)$line$" $inputFile;				 else echo ""; fi | wc -l >> ${inputPrefix}collapsedInputAndMetadataCount.txt; done;
																		#super confused why the > is in the wrong place but this works	
		paste -d'\t' ${inputPrefix}collapsedInputCount.txt ${inputPrefix}collapsed1.txt ${inputPrefix}collapsedInputMetadataCount.txt ${inputPrefix}collapsedInputAndMetadataCount.txt > ${inputPrefix}collapsed.txt  
		echo "	$color240$inputPath/$reset${inputPrefix}collapsed.txt";


		#################################################################
		# Input: sorted tags		Maybe add sort -f		#
		#################################################################
		# Note that to export this, we are first piping to head. With large files, sorting and then scraping the top 200 might provide us only one tag. This way is better, but still may miss some tags.
		cat $inputFile | sed 's/\t//g' | head -$inputLines | sort | awk NF | cut -d " " -f 1  > ${inputPrefix}sortedTags.txt;
		cat $inputFile | sed 's/\t//g' | head -$inputLines | sort | awk NF | cut -d " " -f 2- > ${inputPrefix}sortedTagsMetadata.txt;
		paste ${inputPrefix}sortedTags.txt ${inputPrefix}sortedTagsMetadata.txt > ${inputPrefix}sortedTagsAndMetadata.txt

		cat ${inputPrefix}sortedTags.txt 	 | while read line; do grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedTags.txt 	  | wc -l >> ${inputPrefix}sortedTagsCount.txt; done;
		cat ${inputPrefix}sortedTagsMetadata.txt | while read line; do grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedMetadata.txt | wc -l >> ${inputPrefix}sortedTagsMetadataCount.txt ; done;
		cat ${inputPrefix}sortedTagsAndMetadata.txt | sed 's/\t/ /g' | while read line; do grep "^\([[:blank:]]*\)$line$" $inputFile | wc -l >> ${inputPrefix}sortedTagsAndMetadataCount.txt; done;

		paste -d'\t' ${inputPrefix}sortedTagsCount.txt ${inputPrefix}sortedTags.txt ${inputPrefix}sortedTagsAndMetadataCount.txt ${inputPrefix}sortedTagsMetadata.txt ${inputPrefix}sortedTagsMetadataCount.txt > ${inputPrefix}sorted.txt
		echo "	$color240$inputPath/$reset${inputPrefix}sorted.txt";

		#################################################################
		# Input: unique tags						#
		#################################################################
		# should we limit to 200?
		cat $inputFile | sed 's/\t//g' | sort -u -k1,1 | cut -d " " -f 1  | tail -n +2 > ${inputPrefix}uniqueTags.txt;
		cat $inputFile | sed 's/\t//g' | sort -u -k1,1 | cut -d " " -f 2-  | tail -n +2 > ${inputPrefix}uniqueTagsMetadata.txt;
		paste ${inputPrefix}uniqueTags.txt ${inputPrefix}uniqueTagsMetadata.txt > ${inputPrefix}uniqueTagsAndMetadata.txt

		cat ${inputPrefix}uniqueTags.txt 	 | while read line; do grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedTags.txt 	  | wc -l >> ${inputPrefix}uniqueTagsCount.txt; done;
		cat ${inputPrefix}uniqueTagsMetadata.txt | while read line; do grep "^\([[:blank:]]*\)$line$" ${inputPrefix}collapsedMetadata.txt | wc -l >> ${inputPrefix}uniqueTagsMetadataCount.txt ; done;
		cat ${inputPrefix}uniqueTagsAndMetadata.txt | sed 's/\t/ /g' | while read line; do grep "^\([[:blank:]]*\)$line$" $inputFile | wc -l >> ${inputPrefix}uniqueTagsAndMetadataCount.txt; done;

		paste -d'\t' ${inputPrefix}uniqueTagsCount.txt ${inputPrefix}uniqueTags.txt ${inputPrefix}uniqueTagsAndMetadataCount.txt ${inputPrefix}uniqueTagsMetadata.txt ${inputPrefix}uniqueTagsMetadataCount.txt > ${inputPrefix}unique.txt
		echo "	$color240$inputPath/$reset${inputPrefix}unique.txt";


		# Now clean up files...
		# Several of these are not needed, but I use them sometimes for various things [related to submission QA]. They don't take much processing time, so I left the code in.
		rm ${inputPrefix}column.txt				# not used at all, currently.
		rm ${inputPrefix}collapsedMetadata.txt			# used to count instances of metadata value
		rm ${inputPrefix}collapsedTags.txt			# used to count instances of tag

		rm ${inputPrefix}collapsedInputCount.txt		# Column 1 - Count of how many instances of the tag occur in original tag storm (regardless of metadata or stanza indent block)
		rm ${inputPrefix}collapsed1.txt				# Column 2 - Needed to count how many instances of tag+metadata by comparing to original tag storm
		rm ${inputPrefix}collapsedInputMetadataCount.txt	# Column 3 - Count of how many instances of the metadata occurs in original tag storm (regardless of tag or stanza indent block)
		rm ${inputPrefix}collapsedInputAndMetadataCount.txt	# Column 4 - Count of how many instances of the  tag+metadata occur together in original tag storm (regardless of stanza indent block)
		rm ${inputPrefix}collapsedInput.txt			# Collapsed tag storm, tags after piped to head, used to count instances
		rm ${inputPrefix}collapsedInputMetadata.txt		# Collapsed tag storm, metadata after piped to head, used to count instances
 
		rm ${inputPrefix}sortedTagsAndMetadata.txt		# Needed to count how many instances of tag+metadata by comparing to original tag storm
		rm ${inputPrefix}sortedTagsCount.txt			# Column 1 - Count of how many instances of the tag occur in the original tag storm
		rm ${inputPrefix}sortedTags.txt				# Column 2 - Sorted tag storm tag fields, cut down to number of lines you asked for
		rm ${inputPrefix}sortedTagsAndMetadataCount.txt		# Column 3 - Count of how many instances of the tag+metadata pairs occured in the original tag storm 
		rm ${inputPrefix}sortedTagsMetadata.txt			# Column 4 - Sorted tag storm metadata fields, cut down to number of lines you asked for. 
		rm ${inputPrefix}sortedTagsMetadataCount.txt		# Column 5 - Count of how many instances of the metadata occur in the original tag storm

		rm ${inputPrefix}uniqueTagsAndMetadata.txt		# Needed to count how many instances of tag+metadata by comparing to original tag storm
		rm ${inputPrefix}uniqueTagsCount.txt			# Column 1 - 
		rm ${inputPrefix}uniqueTags.txt				# Column 2 - 
		rm ${inputPrefix}uniqueTagsAndMetadataCount.txt		# Column 3 - 
		rm ${inputPrefix}uniqueTagsMetadata.txt			# Column 4 - 
		rm ${inputPrefix}uniqueTagsMetadataCount.txt		# Column 5 -

		echo "$reset"
		echo "	Files generated. Here is a command you can run on your local computer to download the generated files:"
		echo "$color240	${color81}scp $color25$inputAuth${color240}@${color114}$SERVER$color240:$color207$inputPath/$color203${inputPrefix}${color215}\{${color203}collapsed,sorted,unique$color215\}${color203}.txt ${color203}Desktop/$reset"
		echo ""
		echo "$line1b"
	else
		echo "	No problem, exiting now"
		echo ""
		echo "$line1b"
		echo ""
		exit 0
	fi
	echo ""
	echo ""
