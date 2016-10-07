#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_tagStormSummary.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# 

#################################################################################
# Usage
#################################################################################
#
#	$ tagStormSummary meta.txt x 10 | less -R
#
#	First argument is input file. 
#

#################################################################################
# Limitations
#################################################################################
# with no additional arguments it's kinda slow to create the gradient... which serves no purpose other than scripting challenge with loops.

################################################################################
# Config 
################################################################################
clear

white=`tput setaf 7`
reset=$(echo -en "\033[0m")
color25=$(echo -en "\e[38;5;25m") ;
color28=$(echo -en "\e[38;5;133m") ;
color114=$(echo -en "\e[38;5;114m") ;
color196=$(echo -en "\e[38;5;196m") ;
color202=$(echo -en "\e[38;5;202m") ;
color240=$(echo -en "\e[38;5;240m") ;

#################################################################################
# Arguments									#
#################################################################################
FILE=$1
GETVALUES=$2
FORMAT=$3

if [ -z "$FILE" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then

        printf "\n\n"
        echo "$color240 ╔════════════════════════════════════════════════════════════════════════════════╗$reset"
        echo "$color114   tagStormSummary                                       $color240 github.com/claymfischer" 
        echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
        echo "   ABOUT"
	echo ""
	echo "	Generates a tag storm summary."
	echo ""
	echo "	Shows you all unique tags, their values and metrics on them."
	echo ""
        echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
        echo "   USAGE"
	echo ""
	echo "	$ ${color25}tagStormSummary$color202 meta.txt $reset"
	echo ""
	echo "	Show unique tags and their occurrence count."
	echo ""
	echo "	$ ${color25}tagStormSummary$color202 meta.txt ${color114}x$color240 $reset"
	echo ""
	echo "	The optional ${color114}x$reset will show unique values, bar-separated."
	echo ""
	echo "	$ ${color25}tagStormSummary$color202 meta.txt ${color114}w$color240 $reset"
	echo ""
	echo "	Use ${color114}w$reset if you want the values wrapped to your screen."
	echo "	This is not default behavior as it may flood your terminal."
	echo ""
	echo "	$ ${color25}tagStormSummary$color202 meta.txt ${color114}x$color240 n$reset"
	echo ""
	echo "	Adding the ${color240}n$reset will separate values on a new line instead of by bars."
	echo ""
	echo "	A number instead of ${color240}n$reset will specify how many values you want to see."
	echo "	It will also show the metrics for the tag and individual values."
	echo ""
        echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
        echo "   LIMITATIONS"
	echo ""
	echo "	I am watching the speed carefully. It can process a 30k line tag storm in"
	echo "	milliseconds and I'd like it to stay that fast. I don't think I'd like to"
	echo "	add further functionality, in favor of scalability."
	echo ""
        echo "$color240 ╚════════════════════════════════════════════════════════════════════════════════╝$reset"
        printf "\n\n"
        exit 0	
fi

if [ -s "$FILE" ]; then
        printf "";
else
        printf "\n\n"
        echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
        echo "   The file ${color202}$FILE$reset doesn't appear to exist."
        echo ""

                caseSensitive=$(shopt nocaseglob)
                if [ "$caseSensitive" = "nocaseglob     	off" ]; then
                        shopt -s nocaseglob; { sleep 3 && shopt -u nocaseglob & };
                fi

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

        echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
        printf "\n\n"
        exit 0
fi

#################################################################################
# Tell it to cat the input file, collapse, sort by first field and then cut	#
#################################################################################

if [ -z "$GETVALUES" ]; then
	printf "$color28"

	########################################################################
	# Here is the simple, non-colored version. Works great.
	########################################################################
#	cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1 | awk NF;

	########################################################################
	# here is the slower version where I tested a question I had about loop control and reversal
	########################################################################
	# would be easy to color the output. if even increment by one 6 times (for loop) then add 6, if odd decrement by one six times
	# this really doesn't serve a purpose other than I want practice with more logic in loop control. Good scripting challenge.
	
	########################################################################
	# select a random start color - see ontogeny_palette.sh to pick a color
	########################################################################
	arr[0]="16"
	arr[1]="196"
	arr[2]="88"

	########################################################################
	# 		#
	########################################################################
	rand=$[ $RANDOM % 3 ]
	i=${arr[$rand]}
	k=1
	j=1
	order=1
	rev=1
	########################################################################
	# This is a completely unnecessary loop through color gradients		#
	########################################################################
	cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1 | awk NF | while read line; do \
		################################################################
		# Uncomment to test out loop
		################################################################
		# printf "$reset$i\t$k\t$j\t"; 

		################################################################
		# Begin main loop
		################################################################
		((k++)); ((j++));
		INSTANCES=$(cat $FILE | sed 's/\t//g' | cut -f 1 -d " " | grep -i "^\([[:blank:]]*\)$line$" | wc -l)
		echo -e "$color240$INSTANCES	\e[48;5;${i}m $reset \e[38;5;${i}m${line}"$reset; \
		switch=$(expr $order % 2); \
		goback=$(expr $rev % 2); \
		if [ "$rev" == "1" ]; then
			if [ "$switch" == "1" ]; then
				((i++))
			else
				((i--))
			fi
		else
			if [ "$switch" == "1" ]; then
				((i--))
			else
				((i++))
			fi
		fi
		if [ "$k" == "7" ]; then
			((order++))
			k=1
			if [ "$rev" == "1" ]; then
				if [ "$switch" == "0" ]; then i=$(($i + 7)); else i=$(($i + 5)); fi
			else 
				if [ "$switch" == "0" ]; then i=$(($i - 7)); else i=$(($i - 5)); fi
			fi
		fi
		if [ "$j" == "37" ]; then
			((rev++))
			j=1
			((order++))
			i=$(($i - 6))
		fi
	done;

	########################################################################
	# End useless loop
	########################################################################

	printf "$reset"
else
	########################################################################
	# If they set an argument after the file ($2), check to see if they wanted wrapping
	########################################################################
	if [ "$GETVALUES" != "w" ]; then
		tput rmam; 
		WRAP="\n   Wrapping disabled.\n"
	else
		WRAP="\n   Wrapping enabled.\n"
	fi
	########################################################################
	# did they set a third argument? 
	########################################################################
	if [ -n "$FORMAT" ]; then
		################################################################
		# if a number instead of n, should pipe it to head...
		################################################################
		if [[ $FORMAT == ?(-)+([0-9]) ]]; then
			########################################################
			# $FORMAT is a number.
			########################################################
			numberOfTags=$(cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1  | awk NF | wc -l)

			cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1  | awk NF | \
			while read line; do 
				echo "${color202}$line$reset"; cat $FILE | grep -i "^\([[:blank:]]*\)$line " | sed 's/\t//g' | sort | uniq -c | sed -e 's/^[ \t]*//' | awk NF | head -n $FORMAT | cut -d " " -f 1,3- | sed 's/ /\t/' | awk -F'\t' '{ if ( $1 < 2) $1 = "\t"; else $1 = "[" $1 "]\t"; print $1 $2 }';
				TAGOCCURRENCES=$(cat $FILE | grep -i "^\([[:blank:]]*\)$line " | wc -l)
				UNIQUEINSTANCESCOLLAPSED=$(cat $FILE | grep -i "^\([[:blank:]]*\)$line " | sed 's/\t//g' | awk NF | sort | uniq | wc -l) # We could collapse the white space for a more accurate count.
				if [ "$TAGOCCURRENCES" -gt 1 ]; then
					echo "	${color240}[Tag occurs $color202$TAGOCCURRENCES$color240 times and has $UNIQUEINSTANCESCOLLAPSED unique values]$reset"; 
				fi
				printf "\n\n";
			done 
			echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
			echo "   ${color240}tagStormSummary.sh $FILE ${color202}$2 $3$reset"
			echo
			echo "   Limiting to $FORMAT values for each of the $color202$numberOfTags$reset tags in $FILE."
			printf "$WRAP"
			echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
			echo 
		else
			########################################################
			# Probably worth considering tallying up numbers of instances... adds extra processing. Would be nice to just dump this to a file with random name (to avoid collisions) and reduce processing burden. That would require writing, which may increase overhead processing...
			########################################################
			cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1  | awk NF | while read line; do echo "${color25}$line$reset"; cat $FILE | grep -i "^\([[:blank:]]*\)$line " | sed 's/\t//g' | sort | uniq | awk NF | cut -d " " -f 2- ; printf "\n\n"; done
			echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
			echo "   ${color240}tagStormSummary.sh $FILE ${color25}$2 $3$reset"
			echo
			echo "   Showing all values for each tag in $FILE. Use a number for the third" 
			echo "   argument if this flooded your screen."
			printf "$WRAP"
			echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
			echo
		fi
	else
		################################################################
		# for scalability, if wrap disabled we may as well stop after some number. no reaosn to print a line with 10,000 values if we can only see 10. 
		################################################################
		cat $FILE | sed 's/\t//g' | sort -f -u -k1,1 | cut -d " " -f 1  | awk NF | while read line; do echo "${color114}$line$reset"; cat $FILE | grep -i "^\([[:blank:]]*\)$line " | sed 's/\t//g' | sort | uniq | awk NF | cut -d " " -f 2- | tr '\n' '|' | sed 's/|$//g' | sed 's/|/ | /g' ; printf "\n\n"; done
		echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
		echo "   ${color240}tagStormSummary.sh $FILE ${color114}$2$reset"
		echo
		echo "   Showing all values as bar-separated. Set a third argument to print as lines."
		printf "$WRAP"
		echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
		echo
	fi
	if [ "$GETVALUES" != "w" ]; then
		tput smam &
	fi
fi



