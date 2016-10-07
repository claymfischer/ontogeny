#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_columns.sh
#################################################################################

#################################################################################
# Purpose, usage and limitations						#
#################################################################################
# Purpose
# 	This will color tab-separated columns making them easier to read.
#
# 	For columns < 7, there are hand-picked high-contrast colors. 
# 	For n > 6 and n < 14, the color scheme is extended with more hand-picked colors.
# 	For n > 13, the base 13 colors are used, then random colors. There may be close overlap in color due to random chance.
#
# Usage
# 	$ colorColumns.sh file.txt
#
# Limitations
#	currently does not accept stdin (will add shortly)
# 	Seems to have trouble if columns don't have content in every cell... perhaps pipe through a simple sed 's/\t\t/\t\.\t/g' or more elegant solution
#	Needs expanded usage statement
#	Currently uses tab as delimiter, could easily add a -d flag for user override.
#	If the window is big, sometimes it won't wrap? tput cols = 185... new lines are added, just empt


# To do
# 	The curated colors appear on teh right side of the column. Make them appear first.
#	Fix stdin. It simply needs to know the number of columns to assign colors.

#################################################################################
# Config									#
#################################################################################
color25=$(echo -en "\e[38;5;25m"); 
color117=$(echo -en "\e[38;5;117m"); 
color199=$(echo -en "\e[38;5;199m"); 
color202=$(echo -en "\e[38;5;202m"); 
color240=$(echo -en "\e[38;5;240m"); 
bg25=$(echo -en "\e[48;5;25m"); 
bg107=$(echo -en "\e[48;5;107m"); 
bg196=$(echo -en "\e[48;5;196m"); 
bg200=$(echo -en "\e[48;5;199m"); 
reset=$(echo -en "\033[0m")

FILE=$1
#################################################################################
# Usage statement								#
#################################################################################
if [ -z "$FILE" ] || [ "$FILE" == "-h" ] || [ "$FILE" == "--help" ]; then
	clear
	echo "

$color240  ┌────────────────────────────────────────────────────────────────────────────┐$reset
    $bg200 Color-code columnar data $reset                   $color240     github.com/claymfischer/
   ────────────────────────────────────────────────────────────────────────────$reset
    PURPOSE

	Colors tab-separated (columnar) text, making it easier to read (example 
	below this usage). 

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    USAGE

$color240	$ ${color25}columns$color117 file.txt

$color240	$ cat$color117 file.txt ${color240}| ${color25}columns

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    LIMITATIONS

	Currently hardcoded to use tab as delimiter. Easy to edit:$color240 \\\$'\(${color199}\t${color240}[^${color199}\t${color240}]*\)\{\$COL\}\\\$'$reset

	Assumes equal number of tabs in each row. Wonky if not.

$color240 └────────────────────────────────────────────────────────────────────────────┘$reset


[38;5;240m
First field goes here [1]	Another field, but this one is different! [2]	shortField [3]	Still, it knows how to remain tab-separated... [4]	[0m

[00;38;5;25m[KFirst field goes here[00;38;5;117m[K	Another field, but this one is different![00;38;5;106m[K	shortField[00;38;5;202m[K	Still, it knows how to remain tab-separated...[m[K[m[K[m[K[m[K
[00;38;5;25m[K123[00;38;5;117m[K	Roses are red,[00;38;5;106m[K	[00;38;5;202m[K	It doesn't matter how wide a row in a column is[m[K[m[K[m[K[m[K
[00;38;5;25m[K124[00;38;5;117m[K	Violets are blue,[00;38;5;106m[K	[00;38;5;202m[K	It can still figure it out![m[K[m[K[m[K[m[K
[00;38;5;25m[K125[00;38;5;117m[K	If you were to cat this file[00;38;5;106m[K	[00;38;5;202m[K	Even when a row or column is empty.[m[K[m[K[m[K[m[K
[00;38;5;25m[K126[00;38;5;117m[K	I would have..[00;38;5;106m[K	[00;38;5;202m[K	[m[K[m[K[m[K[m[K
[00;38;5;25m[K127[00;38;5;117m[K	no clue![00;38;5;106m[K	Empty rows are no problem for us![00;38;5;196m[K	[m[K[m[K[m[K[m[K [0m


"
	exit 0
fi
#################################################################################
# Handle input from file vs. stdin (this isn't super reliable)			#
#################################################################################
if [ -t 0 ]; then
	if [ -a "$FILE" ]; then
		printf ""
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
                	echo "	Perhaps you intended to look at one of the following $bg25$similarfiles$reset files? "
			echo "	(setting case insensitive for an instant)" 
                	echo ""
                	echo "                $ ls -d ${FILE:0:1}*$color25"
                	# some directories have a ton fo files that may match, like srr*, so let's split this up to avoid a flood.
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
else
	FILE=stdin
fi


if [ "$FILE" != "stdin" ]; then
	COLS=$(awk -F'\t' '{print NF}' $FILE | sort -nu | tail -n 1) # in case there are varying column counts, let's grab the top
	MINCOLS=$(awk -F'\t' '{print NF}' $FILE | sort -rnu | tail -n 1) # in case there are varying column counts, we may want to exit
else
	# This is the only thing preventing us from piping input in
#	COLS=$( awk -F'\t' '{print NF}' | sort -nu | tail -n 1)
#	MINCOLS=$( awk -F'\t' '{print NF}' | sort -nu | tail -n 1)
	COLS=$2
	MINCOLS=$COLS
fi

#################################################################################
# Main output									#
#################################################################################

	#########################################################################
	# shuffle our colors. 
	#########################################################################
	# Let's start with very different colors to maintain contrast between matches
	BASECOLORS="117 202 106 196 25 201"
	#EXTENDEDCOLORS="240 99 22 210 81 203 105"
	EXTENDEDCOLORS="240 99 64 214 86 210 67"
	# This will extend the colors. This way we avoid colors too similar if only a few search terms, but have a lot of color variety with many search terms
	if [ "$COLS" -lt "7" ]; then
		array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	elif [ "$COLS" -lt "14" ] && [ "$COLS" -gt "6" ]; then
		array=( $(echo "$BASECOLORS $EXTENDEDCOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	else
		NEEDEDCOLORS=$((COLS-12))
		FULLCOLORS=$(shuf -i 17-240 -n $NEEDEDCOLORS)
		array=( $(printf "$BASECOLORS $EXTENDEDCOLORS " | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; echo " $FULLCOLORS" | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	fi
	# Implication here is that the high-contrast colors will appear on the far right, not at left. Could pass to tail and -R...
	#########################################################################
	# initialize stuff for a loop						#
	#########################################################################
	i=$COLS
	COL=1
	COUNTER=$COLS
	COMMAND=""
	#########################################################################
	# a very simple way to color is with grep, and it's fast, so scalable!	#
	#########################################################################
	while [ "$COUNTER" -gt "1" ]; do
		color=${array[i]}
		# To make your eyes hurt, set 38 to 48 instead!
		COMMAND="GREP_COLOR='00;38;5;$color' grep --color=always \$'\(\t[^\t]*\)\{$COL\}\$' | $COMMAND "
		((COUNTER--))
		((COL++))
		((i--))
	done	
	#########################################################################
	# Set up our command loop						#
	#########################################################################
	color=${array[i]} 

	if [ "$FILE" != "stdin" ]; then
		COMMAND="cat $FILE | $COMMAND GREP_COLOR='00;38;5;$color' grep --color=always '.*' | sed 's/^//g'"
	else
		COMMAND="$COMMAND GREP_COLOR='00;38;5;$color' grep --color=always '.*' | sed 's/^//g'"
	fi

	#########################################################################
	# Format and execute							#
	#########################################################################
	if [ "$COLS" != "$MINCOLS" ]; then
		echo
		echo "$color240  ┌────────────────────────────────────────────────────────────────────────────┐$reset"
		echo "    $bg196 Error with file $reset"
		echo "$color240   ────────────────────────────────────────────────────────────────────────────$reset"
		echo "    The file $FILE does not appear to have a consistent number of columns." 
		echo "    The max number of columns we found is $COLS and the minimum number of columns is $MINCOLS."
		echo "    Resulting output may be wonky."
		echo "$color240  └────────────────────────────────────────────────────────────────────────────┘$reset"
		echo
	fi
	# Print out column numbers with header, just in case someone cares...
	echo "$color240"
	if [ "$FILE" != "stdin" ]; then
		cat $FILE | awk -F'\t' ' { for (i=1; i <=NF; ++i) printf "%s [" i "]\t", $i; exit }'
	fi
	echo "$reset"
	# Execute the simple grep loop from above
	echo 
	eval $COMMAND
	echo
	echo $reset


