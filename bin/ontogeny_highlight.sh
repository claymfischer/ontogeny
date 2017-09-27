#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_highlight.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# This highlights terms in a text document various colors for easier visual inspection

#################################################################################
# Usage
#################################################################################
# Run program with no arguments for expanded usage. 
#
#	$ highlight.sh file.txt term1 term2 ... term{n}
#
#	where file.txt can also be "file1.txt file2.txt" or "*.txt" to filter
# 
# If you have a large output, pipe to head or less -R
#
#	$ highlight.sh file.txt term1 term2 | less -R


#################################################################################
# Limitations
#################################################################################
# If doing stdin, it won't give number of occurences
#
# Line numbers should be an argument, not default. It can be annoying.
#
# If doing stdin, it won't give number of occurences
#
# Line numbers should be an argument, not default. It can be annoying.
#
# Maybe if using /dev/null to "filter" in a single file, show context? 
#
# I'd like to add a -f patterns.txt ability
#
# Just added stdin feature, needs QA testing
#
# Does not check if file exists. If a file doesn't exist, it just returns no match. This is probably graceful enough...
#
# If we wanted this to be case-insensitive in our search... or grep -i, which is slow. Apparently converting to all lowercase is faster!
#if [ "$caseSensitive" = "nocaseglob             off" ]; then
#	shopt -s nocaseglob; { sleep 3 && shopt -u nocaseglob & };
#fi
#
# Should we pipe to less -R for more than n lines?
#
# If a pattern is part of a filename with multiple files... well, it works but isn't pretty. Fix.
#
# Each pattern has an occurrence number (occurrence from ALL files), but it would be nice to have total number of occurrences for all patterns

#################################################################################
# Config
#################################################################################
# This is going to run in a subshell, so this should not affect your main shell (where it would affect sort behavior).
export LANG="en_US.UTF-8"
export TERM=xterm-256color


color22=$(echo -en "\e[38;5;22m") ;
color25=$(echo -en "\e[38;5;25m") ;
color69=$(echo -en "\e[38;5;69m") ;
color70=$(echo -en "\e[38;5;70m") ;
color106=$(echo -en "\e[38;5;106m") ;
color114=$(echo -en "\e[38;5;114m") ;
color117=$(echo -en "\e[38;5;117m") ;
color166=$(echo -en "\e[38;5;166m") ;
color196=$(echo -en "\e[38;5;196m") ;
color200=$(echo -en "\e[38;5;200m") ;
color202=$(echo -en "\e[38;5;202m") ;
color240=$(echo -en "\e[38;5;240m") ;

bg25=$(echo -en "\e[48;5;25m") ;
bg106=$(echo -en "\e[48;5;106m") ;
bg114=$(echo -en "\e[48;5;114m") ;
bg117=$(echo -en "\e[48;5;117m") ;
bg196=$(echo -en "\e[48;5;196m") ;
bg200=$(echo -en "\e[48;5;200m") ;
bg202=$(echo -en "\e[48;5;202m") ;
bg220=$(echo -en "\e[48;5;214m") ;
bg240=$(echo -en "\e[48;5;240m") ;

reset=$(echo -en "\033[0m")


#################################################################################
# Handle stdin
#################################################################################
if [ -t 0 ]; then

	if [ "$1" == "pipedinput" ] || [ "$1" == "piped" ] || [ "$1" == "pipe" ]; then 
		echo "No stdin detected."
		exit 1	
	fi

	#################################################################################
	# If no file is found, display help						#
	#################################################################################
	if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		clear
		echo ""
		echo "$color240  ┌────────────────────────────────────────────────────────────────────────────┐$reset"
		echo "    $bg196 A better™ search® $reset				$color240      github.com/claymfischer/
   ────────────────────────────────────────────────────────────────────────────$reset
    Purpose

	A more efficent method of searching. It will highlight your patterns
	in different colors. The colors shuffle each time you use it... just 'cause.

	This was made to simplify searching and show everything together in context.

	It can also be used to filter down to only the lines containing the patterns.
 $color240 ├────────────────────────────────────────────────────────────────────────────┤$reset"
	printf "    Usage: \n\n\t$color240$ highlight ${color25}file.txt$color117 pattern1 pattern2 ... pattern{n}$reset\n\n"
	printf "	$color240$ cat${color25} file.txt$color240 | highlight ${color25}stdin$color117 pattern1 pattern2 ... pattern{n}$reset\n\n"
	printf "	$color240$ cat${color25} file.txt$color240 | highlight ${color25}piped$color117 pattern1 pattern2 ... pattern{n}$reset\n"
	echo "
 $color240 ├────────────────────────────────────────────────────────────────────────────┤$reset
    Patterns with special meaning

	   ${bg117} SPACE $reset highlights any space $color240			\$'\s'$reset

	  ${bg25} SPACES $reset highlights only two or more spaces	$color240	\$'\s\s\+'$reset

	     ${bg114} TAB $reset highlights any tab				${color240}\$'\t'$reset 

	    ${bg106} TABS $reset highlights only two or more tabs		${color240}$'\t\t\+'$reset

	${bg196} SPACETAB $reset highlights space next to a tab/vice-versa	${color240}-e $'\t ' -e $' \t' $reset

	   ${bg202} ASCII $reset highlights any non-ascii characters		${color240}-P '[\x80-\xFF]'$reset

	 ${bg200} CLEANUP $reset highlights areas with multiple spaces or tabs ${color240}$'\t\t\+\|  \+'$reset

     ${bg220} LINENUMBERS $reset highlights the line number, eg. from nl output ${color240}$'^[[:blank:]]*[[:digit:]]\+'$reset

	   ${bg25} DIFFS $reset highlights side-by-side diff output (sdiff -s) ${color240}$'^.*[|<>].*$''$reset

        ${bg240} COMMENTS $reset darkens hashtag comments		 	${color240}$'#.*$'$reset

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    Limitations

	If there is overlap of patterns, put the longer one first or they won't both highlight.
	$color240$ highlight file.txt another ther$reset		${bg25}ano${bg106}ther$reset

	Searching at the beginning of the line is not currently implemented: a choice to
	display the line number (and filename if multiple files) was made, instead.

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    Protips
	
	If searching for numbers, put them as the first patterns. Colored output contains digits.

	Pipe to ${color240}head$reset or ${color240}less -R$reset if your output is going to flood your terminal.

	For a line-by-line view, employ ${color240}tput rmam$reset to remove automatic margins (nowrap), 
	${color240}tput smam$reset will reinstate it (issues may arise in other programs if left on).

	Filename expansion works, and will pass through grep multiple times returning
	only the rows matching all search terms, acting as a filter. Requires quotes.
	$color240 $ highlight $color200\"*.txt\"$color240 pattern1 ... pattern{n} $reset

	You can filter inside a single file by adding /dev/null as a file. For example,
	${color240}$ highlight $color106\"${color240}meta.txt ${color106}/dev/null\"$color240 pattern1 pattern2 ... pattern{n} $reset

	To match one thing OR another in same color, escape the pipe.
	$color240$ highlight file.txt $color202\$'${color240}sra$color202\|${color240}reads$color202'$reset

	To match a space inside a pattern, use an escaped s. 
	$color240$ highlight file.txt $color25\$'${color240}pattern$color25\s${color240}with$color25\s${color240}spaces$color25'$reset
	$color240$ highlight file.txt $color25\$'${color240}one$color25\s${color240}thing$color202\|${color240}or$color25\s${color240}another$color25'$reset

	Extensive regex support! For example, try these types of patterns:
	
	$bg106 ^[[:blank:]]*GEO $reset $bg25 fastq.gz$ $reset $bg200 file_[[:digit:]]*[A-Z] $reset $bg202 ^[[:blank:]]$ $reset $bg117 $'\$' $reset ${bg196}=[^0][[:digit:]]* $reset

 $color240 └────────────────────────────────────────────────────────────────────────────┘$reset
"
	exit 0

	else
		#########################################################################
		# Otherwise, a file was set. 						#
		#########################################################################	
		FILE=$1
	#	if [ -a "$1" ]; then
			INPUT=$(cat $FILE)
			INPUTTEXT="cat $FILE"
			LINECOUNT=$(cat $FILE | wc -l)
	#	else
	#		echo "The file $FILE wasn't found."
	#		exit 0
	#	fi
	fi
else
	if [ "$1" == "pipedinput" ] || [ "$1" == "piped" ] || [ "$1" == "pipe" ] || [ "$1" == "text" ]; then pipedinput="y"; fi
	FILE=stdin
	INPUT=""
	INPUTTEXT=""
fi

#################################################################################
# Pipe to less -R automatically if over 75 lines?				#
#################################################################################
LINES=$(echo $INPUT | wc -l | cut -f 1 -d " ")

	# First arg is the file, so let's just grab args after that
	ARGS=$(for f in $@; do echo "${f}"; done | tail -n +2)
	# Take the above and convert to a number.
	NUMARGS=$(echo "$ARGS" | wc -l | cut -f 1 -d " ")
	# Sometimes multiple files are used, so we need to account for that
	FILENUM=$(for f in $1; do echo "${f}"; done | wc -l | cut -f 1 -d " ")
	# We know that we will be off by at least one argument, because the first arg is the file.
	OFFSET=$((1+FILENUM))
	# This will give us a straight list of our search terms separated from the files
	SEARCHTERMS=$(for f in $@; do echo "${f}"; done | tail -n +$OFFSET)
	# Convert the search terms to a number
	SEARCHTERMNUM=$(echo "$SEARCHTERMS" | wc -l)

	#########################################################################
	# shuffle our colors. Just doing $rand from the array would result in the same color being used multiple times
	#########################################################################
	# Let's start with very different colors to maintain contrast between matches
	BASECOLORS="117 202 106 196 25 201"
	# This will extend the colors. This way we avoid colors too similar if only a few search terms, but have a lot of colo variety with many search terms
	EXTENDEDCOLORS="240 99 22 210 81 203 105"
	NEEDEDCOLORS=$((SEARCHTERMNUM-12))
	if [ "$NUMARGS" -lt "7" ]; then
		array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	elif [ "$NUMARGS" -lt "14" ] && [ "$NUMARGS" -gt "6" ]; then
		array=( $(echo "$BASECOLORS $EXTENDEDCOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	else
		#FULLCOLORS=$(shuf -i 17-240 -n $NEEDEDCOLORS)
		i=0
		FULLCOLORS=$(while [ $i -lt $NEEDEDCOLORS ]; do shuf -i 17-240 -n 1; ((i++)); done)
		array=( $(printf "$BASECOLORS $EXTENDEDCOLORS " | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; echo " $FULLCOLORS" | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
	fi

	#########################################################################
	# Filename expansion and filtering to lines that match all patterns.	#
	#########################################################################
	# Detect if it was used
	FILES=$(for f in $1; do printf "$color240${f}$reset, "; done | sed 's/, $//g')

	# Set it to only return rows we want - filtering when filename expansion is used
	if [ "$FILENUM" -gt "1" ]; then
		RETURNALL=""
		RETURNALL2=""
	else
		RETURNALL="-e ''"
		RETURNALL2="|"
	fi

	#########################################################################
	# Not a graceful way ot get the name/line of a file when looking at multiple files - fix
	#########################################################################
	if [ "$FILE" == "stdin" ]; then
		COMMAND=" grep $SHOWLINENUMBERS '' "
		
	else
		COMMAND="grep $SHOWLINENUMBERS '' $FILE"
	fi
	i=0
	TERMS=0
	OCCURRENCES=""
	TOTES=0
	SEARCH="printf \"
    "
	
	for f in $SEARCHTERMS; do 
		# Count how many pattern matched - NOT how many lines matched - complicated if multiiple files...
		color=${array[i]}
		
		# Set up some search patterns which have special (defined) meaning
		if [ "$f" == "ASCII" ]; then
			OCCURRENCES="\$($INPUTTEXT | LC_CTYPE=C grep -o -P '[\x80-\xFF]'  | wc -l)"
			COMMAND=" $COMMAND | GREP_COLOR='00;48;5;$color' LC_CTYPE=C grep --color=always -P '[\x80-\xFF]$RETURNALL2'"


#$'[[:digit:]]*\.[[:digit:]]*'
# Make a NUM pattern. Highlights integers and floating points.
# Probably do floating point first, then do digits?
# https://superuser.com/questions/655715/regex-does-not-begin-by-pattern

		elif [ "$f" == "FLOAT" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'[^\[;][[:digit:]]\+\.[[:digit:]]\+' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'[^\[;][[:digit:]]\+\.[[:digit:]]\+' $RETURNALL "
		elif [ "$f" == "INT" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'[^[;\.][[:digit:]]\+[^.]' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'[^[;\.][[:digit:]]\+[^.]' $RETURNALL "
		elif [ "$f" == "SPACE" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e ' ' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e ' ' $RETURNALL "
		elif [ "$f" == "SPACES" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e '  \+' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e '  \+' $RETURNALL "
		elif [ "$f" == "TAB" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'\t' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'\t' $RETURNALL "
		elif [ "$f" == "TABS" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'\t\t\+' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'\t\t\+' $RETURNALL "
		elif [ "$f" == "COMMENTS" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'#.*$' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;38;5;240' grep --color=always -e $'#.*$' $RETURNALL "
		elif [ "$f" == "DIFFS" ]; then

			if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e \$'^.*>.*\$' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;28' grep --color=always -e $'^.*>.*\$' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;28m Lines inserted ${OCCURRENCES}\033[0m"

			if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e \$'^.*<.*\$' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;196' grep --color=always -e $'^.*<.*\$' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;196m Lines removed ${OCCURRENCES}\033[0m"

			if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e \$'^.*|.*\$' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;25' grep --color=always -e $'^.*|.*\$' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;25m Lines modified ${OCCURRENCES}\033[0m"
			
		elif [ "$f" == "DIFF" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e $'^.*[|<>].*\$' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'^.*[|<>].*$' $RETURNALL "
		elif [ "$f" == "NUMBERS" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e $'[[:digit:]]' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'[[:digit:]]' $RETURNALL "
		elif [ "$f" == "CLEANUP" ]; then

			if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e \$'\t ' -o -e \$' \t' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;202' grep --color=always -e $'\t ' -e $' \t' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;202m SPACETAB ${OCCURRENCES}\033[0m"

			 if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e '  \+' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;25' grep --color=always -e '  \+' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;25m SPACES ${OCCURRENCES}\033[0m"

			 if [ "$FILE" != "stdin" ]; then OCCURRENCES="(\$($INPUTTEXT | grep -o -e \$'\t\t\+' | wc -l)) "; fi
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;107' grep --color=always -e $'\t\t\+' $RETURNALL "
			SEARCH="$SEARCH \e[38;5;255m\e[48;5;107m TABS ${OCCURRENCES}\033[0m"

			#OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'\t\t\+\|  \+' | wc -l)"
			#COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;202' grep --color=always -e $'\t\t\+\|  \+' $RETURNALL "

		elif [ "$f" == "UUID" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'[[:alnum:]]\{8\}-[[:alnum:]]\{4\}-[[:alnum:]]\{4\}-[[:alnum:]]\{4\}-[[:alnum:]]\{12\}' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'[[:alnum:]]\{8\}-[[:alnum:]]\{4\}-[[:alnum:]]\{4\}-[[:alnum:]]\{4\}-[[:alnum:]]\{12\}' $RETURNALL "
		elif [ "$f" == "SPACETAB" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'\t ' -o -e \$' \t' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'\t ' -e $' \t' $RETURNALL "
		elif [ "$f" == "LINENUMBERS" ]; then
			OCCURRENCES="\$($INPUTTEXT | grep -o -e \$'\t ' -o -e \$' \t' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e $'^[[:blank:]]*[[:digit:]]\+' $RETURNALL "
		else
		# Default pattern match
			OCCURRENCES="\$($INPUTTEXT | grep -o -e '$f' | wc -l)"
			COMMAND=" $COMMAND | LC_CTYPE=C GREP_COLOR='00;48;5;$color' grep --color=always -e '$f' $RETURNALL "
		fi
		if [ "$f" != "CLEANUP" ]; then
			if [ "$FILE" == "stdin" ]; then
				SEARCH="$SEARCH \e[38;5;255m\e[48;5;${color}m ${f} \033[0m"
			else
					SEARCH="$SEARCH \e[38;5;255m\e[48;5;${color}m ${f} ($OCCURRENCES) \033[0m"
			fi
		fi
		((i++))
		((TERMS++))
	done
	#########################################################################
	# This is just to make the filename and line number easier to read
	#########################################################################
	CLEANLINE=
	if [ "$FILENUM" -gt "1" ]; then
		CLEANLINE=$(for f in $1; do echo "${f}"; done | while read line; do printf "$CLEANLINE"; if [ "$line" == "/dev/null" ]; then line="\/dev\/null"; fi; printf " | sed 's/^\\($line\\):\\([[:digit:]]*\\):/\t\\e[38;5;240m\\\1\t\\\2\t\\033[0m/g'"; done)
	else
		CLEANLINE=$(printf " | sed 's/^\\([[:digit:]]*\\):/\\t\\e[38;5;240m\\\1\t\\033[0m/g'")
	fi
	if [ "$FILE" == "stdin" ]; then
		printf ""
	else
		LINECOUNT=", $LINECOUNT lines parsed"
	fi
	#########################################################################
	# Keep in mind this search counts  ALL occurrences, while if highlighting 
	# multiple files you might not see all instances, only the instances where ALL of your terms occur
	#########################################################################
	SEARCH="$SEARCH in $FILES ($TERMS total search patterns$LINECOUNT)\n\n\""
	if [ "$FILE" == "stdin" ] && [ -z "$pipedinput" ]; then
		PRINTSEARCHBAR="$(eval "$SEARCH")"
	elif [ "$pipedinput" == "y" ]; then
		PRINTSEARCHBAR=""
	else
		PRINTSEARCHBAR="$(eval "$SEARCH")"
	fi
	if [ "$1" == "text" ]; then
		COMMAND=$(echo "$COMMAND" | sed 's/48;/38;/g' )
	fi
	printf "$PRINTSEARCHBAR"
	if [ "$pipedinput" != "y" ]; then printf "\n\n"; fi
	
	#########################################################################
	# 
	#########################################################################
	eval "$COMMAND $CLEANLINE"
	printf "$PRINTSEARCHBAR"
	if [ "$pipedinput" != "y" ]; then printf "\n\n"; fi
