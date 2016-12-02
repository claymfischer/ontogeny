#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_columnColorizer.sh
#################################################################################

#################################################################################
# Purpose, usage and limitations						#
#################################################################################
# color columns with no delimiter gray?
#
# This is a minimalist version of the column colorizer. It only accepts stdin, and you can set any delimiter you want as your first argument
#
#	Usage
#		input | colorizer.sh "\t" 2 5

	delimiter="$1"
	if [ -z "$1" ]; then
		delimiter="\t"
	fi
# Silly trick to see if bash will be able to use $1 as an integer
if [ "$2" -eq "$2" ] 2>/dev/null; then
	SPECIFICCOL="y"
else
	SPECIFICCOL=""
fi

	COLS=1
	NUMLINES=0
	# To read leading white space, set IFS and read -r
	while IFS= read -r line; do 
		COLSTHIS=$(echo "$line" | awk -F"$delimiter" '{print NF}' | sort -nu | tail -n 1); 
		if [ "$COLSTHIS" -gt "$COLS" ]; then
			COLS=$COLSTHIS
		fi
		((NUMLINES++))
		 LINES="$LINES 
$line"; done 
	MINCOLS=$COLS

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
					COMMAND="GREP_COLOR='00;38;5;$color' grep --color=always \$'\($delimiter[^$delimiter]*\)\{$COL\}\$\|' | $COMMAND "
					COLUMNLEGEND="\e[38;5;${color}mColumn $i\033[0m  $COLUMNLEGEND"
				fi
				if [ "$f" == "1" ]; then
					FIRSTCOL="y"
				fi
			done
			if [ "$BULLSEYE" = "y" ]; then
				BULLSEYE=
			else
					COMMAND="GREP_COLOR='00;38;5;240' grep --color=always \$'\($delimiter[^$delimiter]*\)\{$COL\}\$\|' | $COMMAND "
					COLUMNLEGEND="\e[38;5;240m $i\033[0m  $COLUMNLEGEND"
			fi

		else
			COLUMNLEGEND="\e[38;5;${color}mColumn $i\033[0m  $COLUMNLEGEND"
			COMMAND="GREP_COLOR='00;38;5;$color' grep --color=always \$'\($delimiter[^$delimiter]*\)\{$COL\}\$\|' | $COMMAND "
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
	COMMAND="echo \"\$LINES\" | tr '\015' '\012' | $COMMAND GREP_COLOR='00;38;5;$color' grep --color=always '.*' | sed 's/^//g'"


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
#	printf "\n$COLUMNLEGEND\n$WALL"
	eval $COMMAND | tail -n +2
#	printf "$WALL\n$COLUMNLEGEND$reset\n\n"
