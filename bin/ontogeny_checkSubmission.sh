#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_spreadsheetInput.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# 

#################################################################################
# Usage
#################################################################################
# Just run the command. It will grab the most recent *meta*, *maniFastq* and *md5* files.
#
# Otherwise you can specify:
#	$ checkSubmission meta.txt maniFastq.txt md5sum.txt
#
# If any additional argument is added, it also checks for ASCII:
#	$ checkSubmission meta.txt maniFastq.txt md5sum.txt x

#################################################################################
# Limitations
#################################################################################
# Doesn't fix anything, just generates a report for you.
# Could cleanse the tags of non-alphanumerics............. cut at the first space on any line
# sed -e 's/[^[:alnum:]|-]//g'
# When displaying tags, maybe count how many unique ones there are.

################################################################################
# Config 
################################################################################

        #########################################################################
        # Color variables							#
        #########################################################################
	reset=`tput sgr0`
	off='\033[0m'
	white=`tput setaf 7`

	color15=$(echo -en "\e[38;5;15m") 
	color25=$(echo -en "\e[38;5;25m") 
	color107=$(echo -en "\e[38;5;107m") 
	color196=$(echo -en "\e[38;5;196m") 
	color202=$(echo -en "\e[38;5;202m") 
	color240=$(echo -en "\e[38;5;240m") 
	bg25=$(echo -en "\e[48;5;25m") 
	bg202=$(echo -en "\e[48;5;202m") 
	bg196=$(echo -en "\e[48;5;196m") 
	bg160=$(echo -en "\e[48;5;160m") 
	bg107=$(echo -en "\e[48;5;107m") 

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

	line1="      ╔════════════════════════════════════════════════════════════════════════════════╗"
	line1m="      ╠════════════════════════════════════════════════════════════════════════════════╣"
	line1b="      ╚════════════════════════════════════════════════════════════════════════════════╝"
	line2="      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	line3=""

        #########################################################################
        # Color variables							#
        #########################################################################
	FILE=$1
	FILE2=$2

	# Default to meta.txt
	# set -h || help || --help to display help
	if [ -z "$FILE" ]; then
		# Let's grab the most recent file that matches the below configuration
		FILE=$(ls -t *meta* | head -n 1)
		if [ -s "$FILE" ]; then
			printf ""
		else
			FILE="help"
		fi
		# FILE="meta.txt"
		ASSUMED=1
	fi
	if [ -z "$FILE2" ]; then
		# Let's grab the most recent file that matches the below configuration
		FILE2=$(ls -t *maniF* | head -n 1)
	fi
	if [ "$FILE" == "-h" ] ; then
		FILE="help"
	fi
	#########################################################################
	# 									#
	# 			HELP/USAGE					#
	# 									#
	#########################################################################
showHelp() {
cat << EOF
	$white$bg196 HELP $reset       					 $color240      github.com/claymfischer $reset
        ------------------------------------------------------------------------------
	ABOUT

		Validates TagStorms to verify their tags are compliant by containing only 
		letters, numbers and underbars.
		
		It works by collapsing a tagstorm, grabbing only the first column, 
		removing blank lines, and then using grep to find lines that contain any
		non alnum class characters:

		cat <FILE> | sed 's/\t//g' | cut -d" " -f 1 | grep -n -v "^[a-zA-Z0-9_]*$" | /
		sed 's/:/\t/g' | sed "s/^/\t/"

		It also shows you which required tags you have or are missing, and 
		gives their values. To avoid clogging your screen these won't fall
		to the next line.
		
        ------------------------------------------------------------------------------
        USAGE

		$ ${color25}checkSubmission meta.txt maniFastq.txt md5sums.txt$reset

		If not defined, it validates the most recently modified *meta*, *maniFastq* and *md5* files:

		$ ${color25}checkSubmission $reset

		To invoke help you can flag with -h, --help or help.

		$ ${color25}checkSubmission ${color196}-h$reset

        ------------------------------------------------------------------------------
        LIMITATIONS

		Does not validate controlled vocabulary, cdwSubmit already does so.

        ------------------------------------------------------------------------------

	
EOF
        }

	#########################################################################
	# 									#
	# 	if file doesn't exist, make suggestion and exit			#
	# 									#
	#########################################################################
	templatenotfound() {
		echo "$WARNINGGRADIENT"
		printf "\n\n"
		echo "        Your input: 	$ $bg25${color15}checkTags $FILE$reset"
		echo ""
		echo "        The file $color196$FILE$reset does not exist"
		echo ""
		similarfiles=$( ls -d ${FILE:0:1}* | sort | wc -l ) 
		echo "        Perhaps you intended to look at one of the following $bg25$similarfiles$reset files (setting case insensitive for an instant):" 
		echo ""
		echo "                $ ls -d ${FILE:0:1}*$color25"
		# some directories have a ton of files that may match, like srr*, so let's split this up to avoid a flood.
		if [ "$similarfiles" -lt 20 ]; then
			ls -d ${FILE:0:1}* | sort | sed "s/^/                /"
		else
			ls -d ${FILE:0:1}* | sort | sed "s/^/                /" | head -15
			echo ""
			echo "                $white[ ... ]$color25"
			echo ""
			ls -d ${FILE:0:1}* | sort | sed "s/^/                /" | tail -15
		fi
		echo ""
		echo "$reset"
		exit 1
	}

#########################################################################
# Begin main output							#
#########################################################################
	clear
	echo ""
	echo ""
	#########################################################################
	# 							#
	#########################################################################
	echo "$line1"
	if [ "$FILE" == "help" ] || [ "$FILE" == "--help" ] || [ "$FILE" == "-h" ]; then
		showHelp
		exit 1
	fi
	#########################################################################
	# First, verify it's a correct file or throw an error.			#
	#########################################################################
	
	if [ -s $FILE ]; then
		printf ""
	else 
		if [ "$ASSUMED" == "1" ]; then
			echo "	We assumed you were looking for meta.txt. We were wrong."
		fi
	        caseSensitive=$(shopt nocaseglob) 
        	if [ "$caseSensitive" = "nocaseglob     	off" ]; then 
        	        shopt -s nocaseglob; { sleep 3 && shopt -u nocaseglob & }; 
        	fi  
		templatenotfound
		exit 1
	fi
	# To remove color can pipe to sed: sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" 
	export GREP_COLOR='00;38;5;240'
	# Make grep output line numbers, and then output empty lines to AWK NF
	TAGS=$(     cat $FILE | sed 's/\t//g' | cut -d" " -f 1 | grep -n -v "^[a-zA-Z0-9_]*$" | sed 's/:/\t/g' | sed "s/^/\t/" | grep --color=always "[a-zA-Z0-9_]" )
	export GREP_COLOR='00;38;5;240'
	FIRSTCHAR=$(cat $FILE | sed 's/\t//g' | cut -d" " -f 1 | grep -n "^[^a-zA-Z_]"        | sed 's/:/\t/g' | sed "s/^/\t/" )

	if [ -n "$TAGS" ] || [ -n "$FIRSTCHAR" ]; then
		if [ -n "$TAGS" ]; then
			echo
			echo "	${bg196}Fail$reset"
			echo
			echo "	The file ${color240}$FILE$reset is non-compliant, and did not pass validation as it contains"
			echo "	${color196}non-alphanumeric or underscore$reset characters. Below are tag(s) you need to fix."
			echo
			echo "$color240$TAGS$reset"
		fi
		if [ -n "$FIRSTCHAR" ]; then
			echo
			echo "	${bg202}Fail$reset"
			echo
			echo "	The file ${color240}$FILE$reset is non-compliant, and did not pass validation looking for"
			echo "	the$color202 first character$reset being alphabetic or an underbar. Below are tag(s) you need to fix."
			echo "$color202		↓$reset"
			echo "$color240$FIRSTCHAR$reset"
		fi
	else
			echo
			echo "	${bg25}Success$reset"
			echo
			echo "	The file ${color25}$FILE$reset is compliant, and successfully passed validation looking for"
			echo "	non-alphanumeric or underscore characters and valid first characters."
		
	fi
	echo
	echo "$line1b"
	echo 

	#########################################################################
	# Check for required tags.						#
	#########################################################################
	REQUIREDTAGS="enriched_in meta assay body_part life_stage data_set_id lab ucsc_db access"
	REQUIREDTAGS="lab data_set_id enriched_in life_stage assay body_part ucsc_db access meta sample_label"
	tput rmam; { sleep 3 && tput smam & };
	for REQUIREDTAG in $REQUIREDTAGS; do 
		if grep -q "^[[:space:]]*$REQUIREDTAG " $FILE; then
			printf "$color240	Tag found: 	";
			TAGPART=$(echo $REQUIREDTAG | cut -f 1 -d' ')
			printf "$TAGPART    "
			if [ "$REQUIREDTAG" == "lab" ]; then printf "   "; fi
			printf "\t"
			printf $reset
			if [ $( grep "^[[:space:]]*$REQUIREDTAG " $FILE | wc -l) -ge 2 ]; then
				grep "^[[:space:]]*$REQUIREDTAG " $FILE | sed 's/\t//g' | cut -f 2- -d' ' | tr '\n' ',' | sed 's/,/, /g' | sed 's/, $//g'
			else
				grep "^[[:space:]]*$REQUIREDTAG " $FILE | sed 's/\t//g' | cut -f 2- -d' ' | tr '\n' ' ' 
			fi
			echo $reset
		else
			echo "	Missing tag: 	$bg160$white$REQUIREDTAG$reset" 
		fi
	done;





	if [ -n "$4" ] ; then
		echo "$line1"
		echo 
		echo "	${bg107} Non-ASCII $reset"
		export GREP_COLOR='00;48;5;107'
		COUNTER=82;
		separator=$(until [  $COUNTER -lt 10 ]; do printf "━"; let COUNTER-=1 ; done;)
		LC_CTYPE=C grep --color=always -n -P '[\x80-\xFF]' $FILE | sed 's/:/\t/g' | while read line; do printf "\n$color107━━━\t$separator$reset\n";  echo "$line" | fmt -w 80 | sed -e '1s/^/ /' -e '2,$s/^/\t/'; done  | sed "s/^/\t/" 
		echo
		echo "$line1m"
		export GREP_COLOR='00;48;5;25'
		echo
		echo "	${bg25} Non-ASCII [trimmed] $reset"
		echo
		echo "	${color25}Trimmed down to only show regions immediately flanking non-ASCII$reset"
		echo
		LC_CTYPE=C grep -n -P -o ".{0,40}[\x80-\xFF].{0,40}" $FILE | sed 's/:/\t/g' | sed "s/^/\t/" | LC_CTYPE=C grep --color=always -P '[\x80-\xFF]'
		echo "$reset"
		echo
		echo "$line1b"
	fi
	echo ""

	# Let's grab the first file that matches the below configuration
	MD5SUMFILE=$(ls *md5* | head -n 1)

	# First check file exists
	if [ -s "$MD5SUMFILE" ]; then
		# next, check that the md5sum column rows are all 32 characters
		MD5SUMCOLUMN=$(cat $MD5SUMFILE | cut -f 1 -d ' ')
		COLUMNLENGTHS=$(echo $MD5SUMCOLUMN | awk '{ print length, $0 }' | cut -f 1 -d ' ' | sort -n | uniq)
		IS32=$(echo $MD5SUMCOLUMN | awk '{ print length, $0 }' | cut -f 1 -d ' ' | sort -n | uniq)
		MD5LENGTH=$(cat $MD5SUMFILE | cut -f 1 -d ' ' | awk '{ print length, $0 }' | cut -f 1 -d ' ' | sort -n | uniq)
		MD5LENGTHS=$(echo $MD5SUMCOLUMN | awk '{ print length, $0 }' | cut -f 1 -d ' ' | sort -n | uniq | wc -l)
		PROBLEMS=0
		if [ "$MD5LENGTH" == "32" ]; then
			
			# Okay, we probably have an md5sum file
			echo "$line1"
			echo
			echo "	Here's an md5sum file we found:$color25 $MD5SUMFILE$reset"
			echo

			# Now check for md5 collisons
			MD5SUMCOLUMNUNIQ=$(echo "$MD5SUMCOLUMN" | sort | uniq | wc -l)
			MD5SUMCOLUMNCOUNT=$(echo "$MD5SUMCOLUMN" | wc -l)
			if [ "$MD5SUMCOLUMNUNIQ" == "$MD5SUMCOLUMNCOUNT" ]; then
				printf ""
			else
				echo "	md5sum collision: there are $bg196$white $MD5SUMCOLUMNUNIQ $reset unique md5sums and $bg196$white $MD5SUMCOLUMNCOUNT $reset total md5sums, checking for collisions with uniq -c:"
				echo "$color196"
				cat $MD5SUMFILE | cut -f 1 -d ' ' | sort | uniq -c | sort -r | grep -v '^ * 1 ' | head
				echo "$reset"
				((PROBLEMS++))
			fi

			# Next check for filename collisions
			FILECOLUMNUNIQ=$(cat $MD5SUMFILE | cut -f 3 -d ' ' | sort | uniq | wc -l)
			FILECOLUMNCOUNT=$(cat $MD5SUMFILE | cut -f 3 -d ' ' | wc -l)
			if [ "$FILECOLUMNUNIQ" == "$FILECOLUMNCOUNT" ]; then
				printf ""
			else
				echo "	File collision: there are $bg196$white $FILECOLUMNUNIQ $reset unique file names and $bg196$white $FILECOLUMNCOUNT $reset total files, check for collisions with uniq -c:"
				echo "$color196"
				cat $MD5SUMFILE | cut -f 3 -d ' ' | sort | uniq -c | sort -r | grep -v '^ * 1 ' | head
				echo "$reset"
				((PROBLEMS++))
			fi

			# Next verify the number of files and md5sums match
			if [ "$FILECOLUMNUNIQ" == "$MD5SUMCOLUMNUNIQ" ]; then
				printf ""
			else
				echo "	Discrepancy: There are $bg196$white $MD5SUMCOLUMNUNIQ $reset unique md5sums and $bg196$white $FILECOLUMNUNIQ $reset unique files, check for this discrepancy$reset"
				((PROBLEMS++))
			fi
			
			if [ "$PROBLEMS" -lt "1" ]; then
				NUMMANIFILES=$(cat $FILE2 | tail -n +2 | wc -l)
				echo "$color240	Appears to be a valid md5sum file for $FILECOLUMNUNIQ files. The manifest ($FILE2) contains $NUMMANIFILES files.$reset"
			fi

			echo
			echo
			echo "$line1b"
		else
			echo "	Found what seemed to be an md5sum file ($color25$MD5SUMFILE$reset) but it doesn't appear valid. The first column is not consistently 32 characters."
		fi
		
	fi

	NEWTAGS=$(
	hgsql cdw -e 'describe cdwFileTags;' | cut -f 2 -d '|' | cut -f 1 | sed 's/ //g' | sed 's/\t//g' | tail -n +2 > ~/.cdwTags.tmp

	cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1  | awk NF | while read line; do 
		
		if grep -iq $line ~/.cdwTags.tmp; then
			printf ""
		else
			printf "$line\n"
		fi

	done | sed 's/^/\t/g'
	)



#	NEWTAGS=$(~clay/bin/tagInDb.sh $FILE | sed 's/^/\t/g')
	if [ "$NEWTAGS" == "" ]; then
		printf ""
	else
		echo ""
		echo "	$bg196 Note: $reset The following tags from $FILE are not currently in our database on $HOSTNAME:"
		echo "$color240"
		echo "$NEWTAGS"
		echo "$reset"
		echo ""
	fi

		printf "\n\n"
	#fi


	exit 1
