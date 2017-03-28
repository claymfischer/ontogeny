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
#	$ cat file.txt | <processing> | columns stdin
#
# Limitations
#	In oder to color columns with stdin, it's processed in a slightly slow way.
#	Currently uses tab as delimiter, could easily add a -d flag for user override.
#
# To do
#	Would be nice to be able to color groups, eg. higlight from column 8-end.
#	$ columns file.tsv 8-
#
#	Maybe color based on indentation...
# hashtag on mani didn't appear

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

	#########################################################################
	# Make a custom border							#
	#########################################################################
		wall() {
			border=1
			WALL=
			WINDOW=$(tput cols)
			while [ "$border" -lt "$WINDOW" ]; do
				WALL="=$WALL";
				((border++))
			done
			export WALL="$reset$color240$WALL$reset"
		}
		wall

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
	below this usage). Color lengends are at the top and bottom, so you can 
	pipe to head or tail and still see column number.

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    USAGE

$color240	$ ${color25}columns$color117 file.txt

$color240	$ cat$color117 file.tsv ${color240}| ${color25}columns ${color117}stdin$reset

	Any additional arguments will be treated as numbers, coloring only those 
	columns (see second example):

$color240	$ ${color25}columns ${color117}file.tsv ${color25}6 19 3$reset 

$color240	$ cat$color117 file.tsv ${color240}| ${color25}columns ${color117}stdin ${color25}6 19 3$reset 

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset

    PROTIPS
	
	Combine with other programs, for instance here's how you can highlight the line numbers.

$color240	$ nl$color117 file.tsv ${color240}| highlight stdin $'^[[:blank:]]*[[:digit:]]*' | ${color25}columns ${color117}stdin$reset 

	If you want to see the top and bottom of a large file, try:

$color240	$ (head; tail) < ${color117}file.tsv$color240 | ${color25}columns ${color117}stdin$reset 

$color240 └────────────────────────────────────────────────────────────────────────────┘$reset


[00;38;5;25m[KColumn 1[00;38;5;117m[K  Column 2[00;38;5;106m[K  Column 3[00;38;5;202m[K  Column 4[m[K[m[K[m[K[m[K  [6 rows]
$WALL
[00;38;5;25m[KFirst field goes here[00;38;5;117m[K	Another field, but this one is different![00;38;5;106m[K	shortField[00;38;5;202m[K	Still, it knows how to remain tab-separated...[m[K[m[K[m[K[m[K
[00;38;5;25m[K123[00;38;5;117m[K	Roses are red,[00;38;5;106m[K	[00;38;5;202m[K	It doesn't matter how wide a row in a column is[m[K[m[K[m[K[m[K
[00;38;5;25m[K124[00;38;5;117m[K	Violets are blue,[00;38;5;106m[K	[00;38;5;202m[K	It can still figure it out![m[K[m[K[m[K[m[K
[00;38;5;25m[K125[00;38;5;117m[K	If you were to cat this file[00;38;5;106m[K	[00;38;5;202m[K	Even when a row or column is empty.[m[K[m[K[m[K[m[K
[00;38;5;25m[K126[00;38;5;117m[K	I would have..[00;38;5;106m[K	[00;38;5;202m[K	[m[K[m[K[m[K[m[K
[00;38;5;25m[K127[00;38;5;117m[K	no clue![00;38;5;106m[K	Empty rows are no problem for us![00;38;5;196m[K	[m[K[m[K[m[K[m[K [0m
$WALL
[00;38;5;25m[KColumn 1[00;38;5;117m[K  Column 2[00;38;5;106m[K  Column 3[00;38;5;202m[K  Column 4[m[K[m[K[m[K[m[K  [6 rows]


[00;38;5;240m[KColumn 1[00;38;5;117m[K  Column 2[00;38;5;240m[K  3[00;38;5;240m[K  4[m[K[m[K[m[K[m[K  [6 rows]
$WALL
[00;38;5;240m[KFirst field goes here[00;38;5;117m[K	Another field, but this one is different![00;38;5;240m[K	shortField[00;38;5;240m[K	Still, it knows how to remain tab-separated...[m[K[m[K[m[K[m[K
[00;38;5;240m[K123[00;38;5;117m[K	Roses are red,[00;38;5;240m[K	[00;38;5;240m[K	It doesn't matter how wide a row in a column is[m[K[m[K[m[K[m[K
[00;38;5;240m[K124[00;38;5;117m[K	Violets are blue,[00;38;5;240m[K	[00;38;5;240m[K	It can still figure it out![m[K[m[K[m[K[m[K
[00;38;5;240m[K125[00;38;5;117m[K	If you were to cat this file[00;38;5;240m[K	[00;38;5;240m[K	Even when a row or column is empty.[m[K[m[K[m[K[m[K
[00;38;5;240m[K126[00;38;5;117m[K	I would have..[00;38;5;240m[K	[00;38;5;240m[K	[m[K[m[K[m[K[m[K
[00;38;5;240m[K127[00;38;5;117m[K	no clue![00;38;5;240m[K	Empty rows are no problem for us![00;38;5;196m[K	[m[K[m[K[m[K[m[K [0m
$WALL
[00;38;5;240m[KColumn 1[00;38;5;117m[K  Column 2[00;38;5;240m[K  3[00;38;5;240m[K  4[m[K[m[K[m[K[m[K  [6 rows]

"
#$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
#    LIMITATIONS
#
#	Currently hardcoded to use tab as delimiter. Easy to edit:$color240 \\\$'\(${color199}\t${color240}[^${color199}\t${color240}]*\)\{\$COL\}\\\$'$reset

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
else
	FILE=stdin
fi

# Silly trick to see if bash will be able to use $1 as an integer
if [ "$2" -eq "$2" ] 2>/dev/null; then
	SPECIFICCOL="y"
else
	SPECIFICCOL=""
fi



if [ "$FILE" != "stdin" ]; then
	COLS=$(awk -F'\t' '{print NF}' $FILE | sort -nu | tail -n 1) # in case there are varying column counts, let's grab the top
	MINCOLS=$(awk -F'\t' '{print NF}' $FILE | sort -rnu | tail -n 1) # in case there are varying column counts, we may want to exit
	NUMLINES=$(wc -l $FILE | cut -f 1 -d " ")
else
	COLS=1
	NUMLINES=0
	# To read leading white space, set IFS and read -r
	while IFS= read -r line; do 
		COLSTHIS=$(echo "$line" | awk -F'\t' '{print NF}' | sort -nu | tail -n 1); 
		if [ "$COLSTHIS" -gt "$COLS" ]; then
			COLS=$COLSTHIS
		fi
		((NUMLINES++))
		 LINES="$LINES 
$line"; done 
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
	EXTENDEDCOLORS="247 99 64 214 86 210 67"
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
		if [ "$SPECIFICCOL" == "y" ]; then

			# First arg is the file, so let's just grab args after that
			ARGS=$(for f in $@; do echo "${f}"; done | tail -n +2)
			for f in $ARGS; do 
				if [ "$f" == "$i" ]; then
					BULLSEYE=y
					COMMAND="GREP_COLOR='00;38;5;$color' grep --color=always \$'\(\t[^\t]*\)\{$COL\}\$\|' | $COMMAND "
					COLUMNLEGEND="\e[38;5;${color}mColumn $i\033[0m  $COLUMNLEGEND"
				fi
				if [ "$f" == "1" ]; then
					FIRSTCOL="y"
				fi
			done
			if [ "$BULLSEYE" = "y" ]; then
				BULLSEYE=
			else
					COMMAND="GREP_COLOR='00;38;5;240' grep --color=always \$'\(\t[^\t]*\)\{$COL\}\$\|' | $COMMAND "
					COLUMNLEGEND="\e[38;5;240m $i\033[0m  $COLUMNLEGEND"
			fi

		else
			COLUMNLEGEND="\e[38;5;${color}mColumn $i\033[0m  $COLUMNLEGEND"
			COMMAND="GREP_COLOR='00;38;5;$color' grep --color=always \$'\(\t[^\t]*\)\{$COL\}\$\|' | $COMMAND "
		fi
		# This $colors variable was just used to see which ansii escape codes are being printed when debugging.
		# colors="$i \e[38;5;${color}m$color\033[0m]    $colors"
		COLHEADER="$COLHEADER\t$COL"
		((COUNTER--))
		((COL++))
		((i--))
	done	

	#########################################################################
	# Set up our command loop						#
	#########################################################################
	if [ "$SPECIFICCOL" == "y" ] && [ "$FIRSTCOL" != "y" ]; then
		color=240
	else
		color=${array[i]} 
	fi
	# These are here in order to color the first column.
	colors="1 [\e[38;5;${color}m$color\033[0m]    $colors"
	COLUMNLEGEND="\e[38;5;${color}mColumn 1\033[0m  $COLUMNLEGEND[$NUMLINES rows]"
	if [ "$FILE" != "stdin" ]; then
		COMMAND="cat $FILE | tr '\015' '\012' | $COMMAND GREP_COLOR='00;38;5;$color' grep --color=always '.*'"
	else
		COMMAND="printf \"\$LINES\" | tail -n +2 | tr '\015' '\012' | $COMMAND GREP_COLOR='00;38;5;$color' grep --color=always '.*'"
	fi
	clear
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
		echo "    Resulting output may be wonky, or those rows may be excluded from this output."
		echo "$color240  └────────────────────────────────────────────────────────────────────────────┘$reset"
		echo
	fi
	# Execute the simple grep loop from above
	if [ "$1" == "piped" -o "$1" == "pipedinput" ]; then printf ""; else printf "$COLUMNLEGEND\n$WALL"; fi
	eval $COMMAND
	if [ "$1" == "piped" -o "$1" == "pipedinput" ]; then printf ""; else printf "$WALL\n$COLUMNLEGEND$reset\n\n"; fi
