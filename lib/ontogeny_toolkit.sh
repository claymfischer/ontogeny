#TO DO prefix lib_


#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_toolkit.sh
#################################################################################

if [ -z "$PS1" ]
then
	# Non-interactive shell should have zero output. This would be when doing scp, using git, etc.
	var=
else
	# Interactive shell can have output for diagnostic reasons, eg. so you know what loaded in a screen session.
	echo "+-------------------------------------------------------------------------------+"
	echo "| Loading $PWD/ontogeny_toolkit.sh					|"
	echo "+-------------------------------------------------------------------------------+"
	echo
fi

	#################################################################################
	# Purpose									#
	#################################################################################
	# This extends a user's .bashrc to take advantage of ontogeny tools and provide
	# aliases to the shell scripts and UNIX command-line tools useful when dealing
	# with big data.
	#
	# The things most users would want to change are at the top (except the PS1 variable near the bottom)

	#################################################################################
	# Install									#
	#################################################################################
	# To use it, source it from your .bashrc and assign the variable ONTOGENY_INSTALL_PATH.
	# For example, in your .bashrc file add the following:
	# 	ONTOGENY_INSTALL_PATH=/home/user/tim/ontogeny
	# 	source $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh

	#################################################################################
	# Configuration									#
	#################################################################################
		# Edit this to what you want. I like a lot of history, and this makes it act sorta like mosh...
		if [ -n "$ZSH_VERSION" ]; then
			var=
		elif [ -n "$BASH_VERSION" ]; then
			unset HISTFILESIZE
			HISTSIZE=50000
			PROMPT_COMMAND="history -a"
			export HISTSIZE PROMPT_COMMAND
			shopt -s histappend
		else
			var=
		fi
		alias gitStatus="git status -uno"
		# Setting LANG to anything other than 'C' may affect sort behavior. 
		# To fix, either 1) set everything =C, 2) LC_COLLATE=C LC_ALL=C after LANG if you insist on using it 3) or sort +0 -1
		# I set LC_ALL at the end which seems to make my sort work as anticipated.
		export TERM=xterm-256color
		export LANG="en_US.UTF-8"
		export LESSCHARSET=utf-8
		export LC_ALL=C
		export VISUAL=vim
		#########################################################################
		# umask line added to allow groups to write to created directories	#
		#########################################################################
		umask 002

	#################################################################################
	# Function/variable libraries								#
	#################################################################################
	# These are prefixed by lib_ to indicate they are not useful on their own, rather
	# they are useful when used inside other functions.

		#########################################################################
		# Color library usage:
		#
		#	echo "Roses are ${color196}red$reset, violets are ${color25}blue$reset..."
		#
		# To see more colors, on your command line run ontogeny_palette.sh:
		#	$ rainbow
		#
		#########################################################################
		# Some of my commonly-used background colors
		bg25=$(echo -en "\e[48;5;25m")
		bg107=$(echo -en "\e[48;5;107m")
		bg117=$(echo -en "\e[48;5;117m")
		bg196=$(echo -en "\e[48;5;196m")
		bg201=$(echo -en "\e[48;5;201m")
		bg202=$(echo -en "\e[48;5;202m")
		bg240=$(echo -en "\e[48;5;240m")
		# Some of my commonly-used foreground colors:
		color25=$(echo -en "\e[38;5;25m")
		color107=$(echo -en "\e[38;5;107m")
		color117=$(echo -en "\e[38;5;117m")
		color196=$(echo -en "\e[38;5;196m")
		color201=$(echo -en "\e[38;5;201m")
		color202=$(echo -en "\e[38;5;202m")
		color240=$(echo -en "\e[38;5;240m")
		color247=$(echo -en "\e[38;5;247m")
		#
		reset=$(echo -en "\e[0m")
		alias removeColor='sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'

		#########################################################################
		# TO DO For bash functions that require a file, use this template to gracefully
		# handle mis-typed filenames.
		#
		# Usage:
		#	if [ ! -s "$FILE" ]; then 
		#		templateNotFound; 
		#		return 0; 
		#	fi
		#########################################################################
		# TO DO: unlimited files. But dunno how to make it list multiple matches.
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

		
		#########################################################################
		# Test if a file is real
		#########################################################################
		isFile() {
			# tests that a file is real, not a directory and has content.
			if [ -f "$1" ]; then 
				return 0; 
			else 
				echo "$1 is not a file." >&2; 
				return 1; 
			fi
		}
		
		#########################################################################
		# Test if files are real
		#########################################################################
		areFiles() {
			# Takes arguments as filenames and tests if they are real.
			# Usage:
			#	$ arFiles file1.txt file*.txt file?.txt
			COMMAND=""
			for x in $@; do 
				COMMAND="$COMMAND isFile $x &&"; 
			done
			COMMAND="$COMMAND return 0"
			eval "$COMMAND"

		}
	


		#########################################################################
		# TO DO - implement
		#########################################################################
		lib_useStdin() {
			if read -t 0; then
				echo "stdin"
				return 1
			else
				echo "file"
				return 0
			fi
		}

		#########################################################################
		# Function to exit if stdin detected
		#
		# Implementation: insert the following at the top of your bash function
		# 	 lib_detectStdin || return 1
		#########################################################################
		error_stdin() {
				printf "\n ${bg196} ERROR $reset stdin detected, $color196${FUNCNAME[2]}$reset does not use stdin\n\n"
				printf "    For more information, try:\n\n"
				printf "    ${FUNCNAME[2]} -h\n\n"
		}
		error_expectsStdin() {
				printf "\n ${bg196} ERROR $reset no stdin detected or file provided, $color196${FUNCNAME[2]}$reset requires a file.\n\n"
				printf "    For more information, try:\n\n"
				printf "\t${FUNCNAME[2]} -h\n\n"
		}
		lib_detectStdin() {
			if [ -t 0 ]; then 
				return 0
			elif [ -z "$1" ]; then
				# They didn't have stdin, therefore we at least need a file...
				error_stdin
				return 1
			else
				error_stdin
				return 1
			fi
		}
		#	
		#
		#
		#
		#

		#########################################################################
		# TO DO - implement
		#########################################################################
		lib_needHelp() {
			# Other scenarios?
			# o - detect stdin when it is not intended?
			# o - file not found
			# o - file not set
			# command not entered correctly - wrong arguments, arguments not integers where expected, etc
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
				echo $@
				return 1
			fi
		}

		lib_numberOfFiles() {
			FILENUM=$(for f in $1; do echo "${f}"; done | wc -l | cut -f 1 -d " ")
			if [ "$FILENUM" -gt "$2" ]; then
				echo "Sorry, too many files."
				return 1
			else
				for f in $1; do if [ ! -s $f ]; then templateNotFound $f; return 1; fi; done
				return 0
			fi
		}

		################################################################################
		# Takes arguments over stdin if both are detected
		################################################################################

		handleStdinB () {
			#a Help
			lib_needHelp "usage"
			if [ $# -lt 2 ]; then # $# is the number of arguments.
				lib_numberOfFiles "$1" 1
				cat
			else
				if lib_numberOfFiles "$1" 1; then
				echo "$*"
				else
					return 0;
				fi
			fi
		}
		exampleFileThenStdin () {
			# Preference will be be given to arguments (file) rather than stdin
			if [ $# -lt 1 ]; then 
				cat
			else
				cat "$*"
			fi
		}
		aDifferentTake() {
			[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"
			cat $input
		}
		#########################################################################
		# TO DO - implement
		#########################################################################
		checkInteger() {
			# simple hack to check if integer. If not an integer, send to stderr. 
			# Example usage if you wanted to know that "1" and "2" were integers:
			#	$ checkInteger 1 && checkInteger 2 && echo "Passed"
			if [ "$1" -eq "$1" ] 2>/dev/null; then 
				return 0;
			else 
				export INTEGERERROR=$(echo "$1 is not an integer." >&2)
				return 1; 
			fi
		}
		checkIntegers() {
			# Upon all integers being validated successfully, will return 0
			# Usage:
			#	$ if checkIntegers a2 8; then echo "TRUE"; else echo "FALSE"; fi
			COMMAND=""
			for x in $@; do 
				COMMAND="$COMMAND checkInteger $x &&"; 
			done
			COMMAND="$COMMAND return 0"
			eval "$COMMAND"
		}
		#########################################################################
		#
		#########################################################################
		lib_fatal () {
			echo "$0: fatal error:" "$@" >&2     # messages to standard error
			return 1
		}

		#########################################################################
		#
		#########################################################################
		test_fatal() {
			if [ $# = 0 ]    # not enough arguments
			then
				lib_fatal not enough arguments
			fi
		}

		#########################################################################
		# Usage: will execute a command if a pipe has any output, for example:
		# 	pipe | pipe | if_read cat | mail -s "you have results"
		#########################################################################
		if_read() { IFS="" read -rN 1 BYTE && { echo -nE "$BYTE"; cat; } | "$@"; };

		#########################################################################
		#
		#########################################################################
		checkExitStatus(){
			# Can be useful for debugging.
			# Usage:
			# 	$ checkExitStatus commands go here
			# 	$ checkExitStatus checkInteger 4a
			#	$ checkExitStatus checkInteger 4 && echo "passed"
			#	$ checkExitStatus checkIntegers 4 5 8 10a && echo "passed"
			"$@"
			local status=$?
			if [ $status -ne 0 ]; then
				echo "Error (exit code $status): $1" >&2
			fi
			return $status
		}

		#########################################################################
		# Takes an argument of unix time and exports variables to divide by, and 
		# variable describing which period it will divide into
		#########################################################################
		unitOfTime() {
        		#########################################################################
        		# Display human-readable time. Make modular so it will work for both  	#
			# time last modified and time last accessed.				#
        		#########################################################################
			# Convert to seconds, then output appropriate time unit
			# unit   	 seconds 
			#-----------------------
			# Year		31536000
			# Month		 2628000
			# Weeks		     n/a	# gonna skip weeks
			# Day		   86400
			# Hour		    3600
			#-----------------------
			local x
			for x in $@; do 
        			PERIOD="years"
        			DIVIDE=31536000
				if [ $x -lt 31536000 ]; then
                			PERIOD="months"
                			DIVIDE=2628000
					if [ $x -lt 2628000 ]; then
						PERIOD="days"
						DIVIDE=86400

						if [ $x -lt 86400 ]; then
							PERIOD="hours"
							DIVIDE=3600 

							if [ $x -lt 3600 ]; then
								PERIOD="minutes"
								DIVIDE=60
								if [ $x -lt 60 ]; then
					    	    	    	    PERIOD="seconds"
					    	    	    	    DIVIDE=1
								fi

							fi
						fi

					fi
				fi
			done
			export PERIOD
			export DIVIDE
		}

		humanTime() {
			if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "Displays when a file was last modified in human-readable time (weeks ago, months ago, etc).\nCan handle unlimited arguments and uses filename expansion.\n\thumanTime file.txt\n\thumanTime *.txt | formatted\n"; return 0; fi
			local x
			for x in $@; do
				# Get the difference between last modification and now.
				MODIFIED=$(( ($(date +%s) - $(date -r $x +%s) )))
				# This will give us the appropriate units and label
				unitOfTime $MODIFIED
        			#########################################################################
        			# Do some math, and format the number of decimal places. I think 2.	#
        			#########################################################################
				if [ "$PERIOD" = "months" ] || [ "$PERIOD" = "years" ]; then
					printf "$x\t%.1f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
				else
					printf "$x\t%.0f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
				fi
				printf '\n'
			done
		}
		# TO DO: Turn UNIX timestamp into human-readable time
		# TO DO: send ls error: $ ls *.notreal 2>/dev/null
		#########################################################################
		# Make a custom border							#
		#
		# Usage: if you call it inside a function, it will generate a wall spaced
		# 	 to your current terminal window size. If you echo $WALL without
		#	 calling it inside the function, it will make a wall the size of
		#	 the terminal window when this file was first sourced (at login).
		#
		#	myFunction() {
		#		wall
		#		echo "$WALL"
		#	}
		#
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
	# In-progress functions/temporary aliases
	#################################################################################
		# I edit my .bashrc often enough that this is useful to me.
		alias load='source ~/.bashrc; source ~/.bash_profile'
		alias bashrc='vi ~/.bashrc'
		alias ontogeny_toolkit='vi $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh'
		
	#################################################################################
	# General UNIX/Linux tools							#
	#################################################################################

		#########################################################################
		# Screen formatting (temporary)						#
		#########################################################################
		alias noWrap='tput rmam; { sleep 20 && tput smam & };'

		#########################################################################
		# General UNIX/linux aliases						#
		#########################################################################
		alias l='ls -lph --time-style="+%I:%M %p, %a %b %d, %Y"'
		alias lf="ls -lph | egrep -v '^d'"
		alias ldir="ls -lph | egrep '^d' | GREP_COLORS='mt=38;5;25' grep --color=always -P '\S+\/$|'"

		#########################################################################
		# Visualize ascii
		# usage:
		#	cat file.txt | ascii
		#	cat file.txt | nonascii
		#########################################################################
		alias nonascii=' GREP_COLOR="00;48;5;107" LC_CTYPE=C grep --color=always -n -P "[\x80-\xFF]"  | sed "s/:/\t/g" | while read line; do printf "\n"; echo "$line" | fmt -w 150 | sed -e "1s/^/ /" -e '\''2,$s/^/\t/'\''; done  | sed "s/^/\t/" | sed "1s/^/\n\t $bg107 non-ascii characters $reset $bg240 in context $reset\n/"; printf "\n\n"'
		alias    ascii=' GREP_COLOR="00;48;5;202" LC_CTYPE=C grep -n -P -o ".{0,40}[\x80-\xFF].{0,40}" | sed "s/:/\t/g" | sed "s/^/\t/" | GREP_COLOR="00;48;5;202" LC_CTYPE=C grep --color=always -P "[\x80-\xFF]" | sed "1s/^/\n\t$bg202 non-ascii characters $reset $bg240 trimmed from context $reset\n\n/"; printf "\n\n"'

		#########################################################################
		# Visualize  where you have tabs and multiple spaces. Usage: 
		#	cat file.txt | cleanUp
		#########################################################################
		alias cleanUp=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;117' grep --color=always -e \$'\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg117 tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		alias cleanUpToo=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;107' grep --color=always -e \$'\t\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg107 multiple tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		alias cleanUpEnds="GREP_COLOR='00;48;5;117' grep --color=always -e \$' \$' -e '' |   GREP_COLOR='00;48;5;201' grep --color=always -e \$'\t\$' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg201 tab line endings $reset $bg117 space line endings $reset $reset\n\n/' | sed -e \"\\\$a\\ \""

		#########################################################################
		# This is useful for looking for chunks that match a pattern, eg. 	#
		# errors in a log file.	Gives you nicely formatted output.		#
		#									#
		#	$ showMatches file.txt pattern [10]				#
		#									#
		#	The pattern can use basic regex.				#
		#	Optional [10] integer sets amount of context to display		#
		#########################################################################
		showMatches() {
			# TO DO - color the numbers? or add a pipe after them.
			lib_detectStdin || return 1
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ showMatches file.txt pattern 10"; return 0; fi
			if [ -s "$1" ]; then
				if [ "$2" == "" ]; then echo "You didn't provide a valid pattern"; return 0; fi
				DIVISIONBORDER="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
				if [ -z "$3" ]; then NUMBER=5; else NUMBER=$3; fi
				cat $1 | nl --body-numbering=a | sed "s/\(.*$2.*\)/$DIVISIONBORDER\n\1/g" | grep --no-group-separator -A$NUMBER "$DIVISIONBORDER" | GREP_COLOR='00;48;5;201' grep --color=always "$2\|"  | sed 's/^\([[:blank:]]*[[:digit:]]\+\)/\1 | /g'
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		#########################################################################
		# This will show the content between two patterns. 
		#
		# Limitations: Note that the first match is used.
		# 
		# Usage: 
		#	grabBetween file.txt pattern1 pattern2
		#
		#########################################################################
		grabBetween(){
			lib_detectStdin || return 1
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ grabBetween file.txt firstPattern secondPattern"; return 0; fi
			if [ -s "$1" ]; then
				cat $1 | grep --no-group-separator -A5000 $2 | grep --no-group-separator -B5000 -m1 $3 | GREP_COLOR='00;48;5;25' grep --color=always "$2\|" | GREP_COLOR='00;48;5;107' grep --color=always "$3\|"
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		#########################################################################
		# Same as above, but lets' you grab specific range between two line numbers.
		#########################################################################
		grabLines(){
			lib_detectStdin || return 1
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ grabLines file.txt firstLineToGrab lastLineToGrab"; return 0; fi
			if [ -s "$1" ]; then # TO DO: what if numbers don't make sense? checkfor integers.
				cat $1 | nl --body-numbering=a | sed 's/^[[:blank:]]*//g' | grep --no-group-separator -A5000 $"^$2" | grep --no-group-separator -B5000 -m1 $"^$3" | GREP_COLOR='00;48;5;25' grep --color=always "^$2[[:blank:]]\+.*$\|" | GREP_COLOR='00;48;5;107' grep --color=always "^$3[[:blank:]]\+.*$\|" # TO DO: awk '{$1=""; print $0}' FS='\t' OFS='\t' | sed 's/^\t//g'
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		# a minimalist form TO DO no numbers... maybe cal grabContent
		showLines(){
			lib_detectStdin || return 1
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ grabLines file.txt firstLineToGrab lastLineToGrab"; return 0; fi
			if [ -s "$1" ]; then
				cat $1 | nl --body-numbering=a | sed 's/^[[:blank:]]*//g' | grep --no-group-separator -A5000 $"^$2" | grep --no-group-separator -B5000 -m1 $"^$3" | awk '{$1=""; print $0}' FS='\t' OFS='\t' | sed 's/^\t//g'
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
	
		numberLines() {
			lib_detectStdin || return 1
			cat $1 | nl --body-numbering=a | sed 's/^[[:blank:]]*//g'
		}

		#########################################################################
		# Same as above, but for fastq.gz. This lets you grab between two line numbers.
		#########################################################################		
		checkFastq(){
			lib_detectStdin || return 1
			# Grabs content between two line numbers.
			# Usage (to grab content between line 100 and 200):
			#	checkFastq file.fastq.gz 100 200
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ checkFastq file.txt firstLine bottomLine"; return 0; fi
			# Verify line numbers are integers
			if [ "$2" -eq "$2" ] 2>/dev/null; then firstLine=$2; else echo "First line number must be an integer."; return 0; fi
			if [ "$3" -eq "$3" ] 2>/dev/null; then secondLine=$3; else echo "Second line number must be an integer."; return 0; fi
			if [ -s "$1" ]; then
				# nl --body-numbering=a
				zcat $1 |  nl --body-numbering=a | grep --no-group-separator -A5000 $firstLine | grep --no-group-separator -B5000 -m1 $secondLine | GREP_COLOR='00;48;5;25' grep --color=always "$firstLine\|" | GREP_COLOR='00;48;5;107' grep --color=always "$secondLine\|"
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		#########################################################################
		# Text file pipeline functionality					#
		#########################################################################

			#########################################################################
			# This is for files that sometimes don't have a newline on the last line... it messes things up...
			#########################################################################
			alias fixLastLine="sed -e '\$a\'"

			#########################################################################
			# Data from Windows or some rich text will have lines end with both a carriage return and newline character, this fixes it.
			#########################################################################
			alias fixCLFR="sed -e 's/[\\r\\n]//g'"
			alias fixNewLines=fixCLFR

			#########################################################################
			# This will remove all blank lines in a file.
			#########################################################################
			alias deleteBlankLines="sed '/^\s*$/d' "

			#########################################################################
			# These will reduce multiple blank lines/spaces to one.
			#########################################################################
			alias reduceMultipleBlankLines='grep -A1 . | grep -v "^--$"'
			alias reduceMultipleBlankSpaces="sed 's/  */ /g'" # tr -s ' ' works too and is simpler!
			alias reduceMultipleWhitespaces="sed 's/\t*\t/\t/g' | sed 's/ * / /g'"

			#########################################################################
			# To get the average number of characters in each column:
			#
			# 	cat file.tab | columnLengths
			#########################################################################
			alias columnLengths="awk ' { thislen=length(\$0); printf(\"%-5s %d\n\", NR, thislen); totlen+=thislen} END { printf(\"average: %d\n\", totlen/NR); } '"

			#########################################################################
			# To get the average number of characters in one column:
			#
			# 	cut -f 3 file.tsv | columnAvg
			#########################################################################
			alias columnAvg="awk '{ thislen=length(\$0); totlen+=thislen} END { printf(\"%d\n\", totlen/NR); }'"
			#########################################################################
			# Counts non-blank lines
			# Usage:	linesNotEmpty file.txt
			#########################################################################
			alias linesNotEmpty='grep -c "[^ \\n\\t]"'
			#########################################################################
			# Counts lines that have content - no blank lines, no comments
			# Usage:	cat file.txt | linesContent
			#########################################################################
			alias linesContent='grep -v "^#" | grep -c "[^ \\n\\t]"'
			#########################################################################
			# Returns number of columns in a file. Only looks at header, assumes consistent columns per row.
			# Usage:	numColumns file.tsv
			#########################################################################
			alias numColumns="awk -F '\t' '{print NF; exit}'"
			#########################################################################
			# Returns maximum number of columns in a file.
			# Usage:	cat file.tsv | maxColumns
			#########################################################################
			alias maxColumns="awk -F'\t' '{print NF}' | sort -nu | tail -n 1"
			#########################################################################
			# Returns minimum number of columns in a file.
			# Usage:	cat file.tsv | minColumns
			#########################################################################
			alias minColumns="awk -F'\t' '{print NF}' | sort -nu | head -n 1"

			#########################################################################
			# Show column number and header for tab-separated files
			# A very simple way to do this without awk: head -n 1 file.tsv | sed 's/\t/\n/g' | nl
			# Usage:
			# 	whichColumn file.tsv
			#########################################################################
			alias whichColumn="awk -F'\t' ' { for (i = 1; i <= NF; ++i) print i, \$i; exit } ' "

			#########################################################################
			# Shows column numbers with header and example row for tab-separatd files. 
			# Usage:
			# 	cat file.tsv | whichColumns
			#########################################################################
			alias whichColumns=" head -n 2 | awk -F'\t' '{ for (i = 1; i <= NF; i++) f[i] = f[i] \"     \t\" \$i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^ */, \"\", f[i]) ; for (i = 1; i <= n; i++) print i, f[i] } ' | column -ts $'\t'"

			#########################################################################
			# Same as whichColumns, but can use directly on a file instead of end of a pipe.
			# Usage:
			#	describeColumns file.tsv
			#########################################################################
			describeColumns() {
				head -n 2 $1 | awk -F'\t' '{ for (i = 1; i <= NF; i++) f[i] = f[i] "     \t" $i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^ */, "", f[i]) ; for (i = 1; i <= n; i++) print i, f[i] } ' | /usr/bin/iconv -t utf-8 -c |  /usr/bin/column -ts $'\t'
			}

			#########################################################################
			# TO DO Get column size summaries: mean, mode, median, min, max num of characters
			#########################################################################
			transpose() {
			awk '
				BEGIN { FS=OFS="\t" }
				{
    	    	    	    	    for (rowNr=1;rowNr<=NF;rowNr++) {
        				cell[rowNr,NR] = $rowNr
    	    	    	    	    }
    	    	    	    	    maxRows = (NF > maxRows ? NF : maxRows)
    	    	    	    	    maxCols = NR
				}
				END {
    	    	    	    	    for (rowNr=1;rowNr<=maxRows;rowNr++) {
        				for (colNr=1;colNr<=maxCols;colNr++) {
            	    	    	    	    printf "%s%s", cell[rowNr,colNr], (colNr < maxCols ? OFS : ORS)
        				}
    	    	    	    	    }
				}' $1
			}


			#########################################################################
			# Gives a breakdown of a tab-separated file, allowing you to choose delimiter (defaults to tab)
			#
			#	o - Tells you how many rows and columns are present using delimiber
			#	o - Alerts if funky line breaks are present
			#	o - Alerts if column numbers vary amongst the rows
			#	o - Column number
			#	o - Column header
			#	o - Unique values from that column
			#	o - Mean characters in that column
			#	o - Gives random values from that column, and allows you to truncate them (default truncate is 15)
			#	
			# Usage:
			#	summarizeColumns file.tsv
			#########################################################################
			summarizeColumns() {
				clear
				wall
				if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then 
					echo
					echo "Usage:"
					echo
					echo "	${color117}summarizeColumns$color107 file.txt$reset"
					echo
					echo "Summarizes columns and gives random example values from each column."
					echo
					echo "	${color117}summarizeColumns$color107 file.csv $color25'delimiter'$reset"
					echo
					echo "$color240	If no delimiter is specified, defaults to tab.$reset"
					echo
					echo "	${color117}summarizeColumns$color107 file.tsv ${color25}tab$reset 5 50"
					echo
					echo "$color240	If no integer is specified, defaults to 5 examples per column, and truncates to 15 characters.$reset"
					echo
					return 0;
				fi
				if [ -a "$1" ]; then
					if [ -z "$2" ] || [ "$2" == "tab" ]; then 
						delimiter=$'\t'
						aligningOn="tab"
					else
						# Should we just take first letter of the delimiter?
						delimiter=$2
						aligningOn=$2
					fi
					if [ -z "$3" ]; then
						howMany=5
					else
						if [ "$3" -eq "$3" ] 2>/dev/null; then
							howMany=$3
						else
							howMany=5
						fi
					fi
					export COLS=$(awk -F"$delimiter" '{print NF}' $1 | sort -nu | tail -n 1)
					export CURRENTCOL=1
					export totalAvg=0
					export colLength=0
					export truncate=
					if [ -z "$4" ]; then truncateThis=15; else truncateThis=$4; fi
					output="#	column title	uniq vals	avg char.	$color25$howMany$reset random values (truncated to $truncateThis characters)
$WALL"
					while [ $CURRENTCOL -le $COLS ]; do 
						# add up column averages
						colAvg=$(cut -f $CURRENTCOL -d"$delimiter"  $1 | tail -n +2 | awk ' { thislen=length($0); totlen+=thislen} END { printf("%d\n", totlen/NR); } ')
						totalAvg=$(($colAvg+$totalAvg))
						colTitle=$(cut -f $CURRENTCOL -d"$delimiter"  $1 | head -n +1 )
						if [ "$colTitle" == "" ]; then colTitle="<BLANK COLUMN HEADER>"; fi
						COLOR=`echo -e "\e[38;5;${color}m"`
						COLORBLANK=`echo -e "\e[38;5;25m"`
						NORMAL=`echo -e '\033[0m'`
						crlf=$(grep -U $'\015\|\x0D' $1 | wc -l)
						# sed "s/^\(.\{0,$truncateThis\}\).*/\1/"
					#	randValues=$(cut -f $CURRENTCOL -d"$delimiter"  $1 | tail -n +2 | sort -R | uniq | head -n $howMany | tr '\n' ',' | sed "s/^/$COLOR/g" | sed "s/,[[:blank:]]*$//g" | sed "s/,/$NORMAL, $COLOR/g"; echo "$reset" )
						randValues=$(cut -f $CURRENTCOL -d"$delimiter"  $1 | tail -n +2 | sort -R | uniq | head -n $howMany | while read line; do if [ "$line" == "" ]; then printf "${color25}BLANK"; line2="^[[:blank:]]*$"; else line2=$line; fi; printf "$line" | sed "s/^\(.\{0,$truncateThis\}\).*/\1/"; printf " $reset["; cut -f $CURRENTCOL -d"$delimiter" $1 | grep "$line2" | wc -l | tr '\n' ']'; printf ","; done |  sed "s/^/$COLOR/g" | sed "s/,[[:blank:]]*$//g" | sed "s/,/$NORMAL, $COLOR/g"; echo "$reset" )
						uniqueValues=$(cut -f $CURRENTCOL -d "$delimiter" $1 | tail -n +2 | sort | uniq | wc -l)
						output="$output
$CURRENTCOL	$(echo "$colTitle" | sed "s/^\(.\{0,30\}\).*/\1/")	$uniqueValues	$colAvg	$randValues"
						export colLength="$colLength $colAvg"
						((CURRENTCOL++))
					done
					echo "$WALL"
					echo "$output" | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $'\t' #| sed "s/<BLANK COLUMN HEADER>/$COLORBLANK<BLANK>$NORMAL/g"
					maxColumns=$(cat $1 | awk -F"$delimiter" '{print NF}' | sort -nu | tail -n 1)
					minColumns=$(cat $1 | awk -F"$delimiter" '{print NF}' | sort -nu | head -n 1)
					if [ "$maxColumns" == "$minColumns" ]; then
						columnDetails="$maxColumns columns"
					else
						columnDetails="an inconsistent column numbers among the rows. The most columns is $maxColumns, and the least is $minColumns"
					fi
					if [ "$crlf" = "0" ]; then CRLF=""; else CRLF="\n\n$bg196 WARNING $reset this file uses clrf for newlines. Please fix them  ($color240$ cat $1 | fixNewLines > ${1}.fixed$reset)"; fi
					echo "$WALL"
					printf "${color25}$1$reset contains $(($(cat $1 | wc -l) - 1)) rows and ${columnDetails} using $bg25 $aligningOn $reset as a delimiter. $CRLF\n"
					echo "$WALL"
				else 
					#echo "File doesn't exist"
					templateNotFound $1
				fi
			}

			#########################################################################
			# This is designed to use in a pipeline to remove any number of columns
			# from 0 to infinite. They must be integers and can be in any order.
			#
			# Alerts to columns that didn't get removed (due to not being integers)
			# 
			# Usage:
			# 	cutColumns file.tab 1 2 3
			#########################################################################
			cutColumns() {
				lib_detectStdin || return 1
				# TO DO: make first argument the delimiter.
				# usage
				if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then 
					echo "Cuts columns from a file and prints to stdout. Does not alter original file."
					echo
					echo "	$ removeColumns file.txt 2 6 9 5"
					echo
					return 0
				fi
				# First arg is the file, so let's just grab args after that
				ARGS=$(for f in $@; do echo "${f}"; done | tail -n +2)
				# Sometimes multiple files are used, so we need to account for that
				FILENUM=$(for f in $1; do echo "${f}"; done | wc -l | cut -f 1 -d " ")
				# error if too many files
				if [ "$FILENUM" -gt 1 ]; then echo "Please use only one file."; return 0; fi

				# We know that we will be off by at least one argument, because the first arg is the file.
				OFFSET=$((1+FILENUM))
				# This will give us a straight list of our arguments separated from the files
				ARGTERMS=$(for f in $@; do echo "${f}"; done | tail -n +$OFFSET)
				# Convert the argument terms to a number
				ARGTERMNUM=$(echo "$ARGTERMS" | wc -l)
				i=0
				argnum=1
				notRemoving=
				columnsToRemove=
				for f in $ARGTERMS; do 
					# Test for integer
					if [ "$f" -eq "$f" ] 2>/dev/null; then
						#INTEGER="y"
						columnsToRemove="$columnsToRemove \$$f=\"REMOVETHISCOLUMN\"; "
					else
						notRemoving="$notRemoving $bg196 $f $reset"
					fi
					((argnum++))
					((i++))
				done
				COMMAND="awk '{$columnsToRemove print \$0}' FS='\t' OFS='\t' $1 | sed 's/REMOVETHISCOLUMN\t//g' | sed 's/\tREMOVETHISCOLUMN//g'"
				eval "$COMMAND"
				if [ -n "$notRemoving" ]; then
					echo "The following columns were not removed: $notRemoving"
				fi
			}
			alias nukeColumns=cutColumns
			alias removeColumns=cutColumns

		#########################################################################
		# If you need a quick folder, don't use foo or temp...			#
		#########################################################################
 		alias mkdirRand='mkdir "$(date +%F)-$RANDOM"'
		alias mkdirNow='mkdir "$(date +%F)-$(date +"%H_%M_%S")"'
		alias mkdirTime='mkdir "$(date +"%H_%M_%S")"'
		alias foo='mkdir "$(date +"%b_%d")_$(date +"%I_%M_%p")"'
		# Test if current directory is actively writing to / removing from disk (as du takes time to execute, I would not rely on its accuracy, just as a way of knowing something is being written)
		alias writing='echo ""; echo "$(( ($(du  --apparent-size -s | cut -f 1) - $(sleep 1; du --apparent-size -s | cut -f 1)) / -1 | bc -l  )) bytes written in the last second in $PWD"; printf "\n\n"'

		#########################################################################
		# Directory/text file inspection/summary
		# 
		#	Overwhelmingly these are not intended to be part of a pipeline,
		#	they are intended to help visualize intermediate states while 
		#	building up your pipeline.
		#
		#########################################################################

			#########################################################################
			# This is a way of looking at the top and bottom of a file.
			#########################################################################
			headAndTail() {
				lib_detectStdin || return 1
				if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ inspect file 10"; return 0; fi
				if [ -s "$1" ]; then
					wall
					BIGENOUGH=$(wc -l $1 | cut -f 1 -d " ")
					if [ -z "$2" ]; then PREVIEWLINES=5; else PREVIEWLINES=$2; fi
					if [ "$BIGENOUGH" -gt "20" ]; then
						(echo "$WALL"; head -n $PREVIEWLINES; echo $WALL; nl --body-numbering=a  | sed 's/^\([[:blank:]]*[[:digit:]]\+\)\t/\1 /g' | tail -n $PREVIEWLINES; echo $WALL) < $1 
					else
						echo "This file is too small to bother inspecting the head and tail."
					fi
				else
					echo "Please provide a filename that exists and has content."
				fi
			}

			alias inspect=headAndTail

			#########################################################################
			# Pipe to this to align by tabs.
			# Usage: 
			# 	$ cat file.txt | pipeline | format
			#########################################################################
			alias format="sed 's/\t\t/\t.\t/g' | sed 's/.\t\t/.\t.\t/g' | sed 's/\t$/\t./g' | sed 's/.\t$/\t./g' | sed 's/^\t/.\t/g' | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $'\t' | sed '1s/^/\n$WALL\n/'; printf '$WALL\n\n'"

			#########################################################################
			# Same as above, but let's you choose the delimiter. Defaults to tab if no delimiter set.
			# Usage:
			#	cat file.txt | pipeline | formatted "delimiter"
			#########################################################################
			formatted() {
				
				if [ -z "$1" ] || [ "$1" == "tab" ]; then 
					delimiter=$'\t'
				else
					delimiter=$1
				fi
				sed 's/  \+/ /g' | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $"$delimiter"
			}

			#########################################################################
			# View a file aligned by a delimiter. Defaults to tab if no delimiter set.
			# Usage:
			#	align file.tsv
			#########################################################################
			align() {
				wall
				if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then 
					echo
					echo "Usage:"
					echo
					echo "	${color117}align$color107 file.txt $color25'delimiter'$reset"
					echo
					echo "$color240	If no delimiter is specified, defaults to tab.$reset"
					echo
					return 0;
				fi
				if [ -z "$2" ] || [ "$2" == "tab" ]; then 
					delimiter=$'\t'
					aligningOn="tab"
				else
					delimiter=$2
					aligningOn=$2
				fi
				tput rmam
				echo 
				echo "$reset${color240}Aligned with $reset$bg25 $aligningOn $reset ${color240}as delimiter.$reset"
				echo "$WALL" 
				cat $1 | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $"$delimiter"
				#cat $1 | sed "s/$2$2/$2.$2/g" | sed "s/.$2$2/.$2.$2/g" | sed "s/$2$/$2./g" | sed "s/.$2$/$2./g" | sed "s/^$2/.$2/g" | column -ts $"$2"
				echo "$WALL"
				tput smam
			}
			alias splitAndAlign=align
			alias breakAndSeparate=align
			alias chop=align
			alias explode=align

			#########################################################################
			# This is like align, but it adds in some strings to be cut out to make 
			# the grid later. Not really a useful tool on its own. it Also truncates
			# columns so they don't spill over the side of the screen.
			# Usage:
			#	arrange file.txt 'delimiter' 100|avg
			#########################################################################
			arrange() {
				wall
				if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then 
					echo
					echo "Usage:"
					echo
					echo "	${color117}arrange$color107 file.txt $color25'delimiter'$reset"
					echo
					echo "$color240	If no delimiter is specified, defaults to tab.$reset"
					echo
					echo '"tab" and "space" can be typed as delimiters.'
					echo
					return 0;
				fi
				if [ -z "$2" ] || [ "$2" == "tab" ]; then 
					delimiter=$'\t'
					aligningOn="tab"
				elif [ "$2" == "space" ]; then
					delimiter=" "
					aligningOn="space"
				else
					# Should we just take first letter of the delimiter?
					delimiter=$2
					aligningOn=$2
				fi
				# this will take CUTMEOUT into consideration, so we need to add 10. The first line will also be about 8 characters longer.
				if [ -z "$3" ]; then 
					cat $1  | sed 's/^/CUTMETOO/g' | sed "s/$delimiter/${delimiter}CUTMEOUT/g" | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | while read line; do echo "$line" | tr "$delimiter" '\n' | while read line; do echo "$line" | sed "s/^\(.\{0,50\}\).*/\1/"  | tr '\n' "$delimiter"; done; printf "\n"; done | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $"$delimiter"	
				elif [ "$3" == "average" ] || [ "$3" == "avg" ]; then
					export COLS=$(awk -F"$delimiter" '{print NF}' $1 | sort -nu | tail -n 1)
					export CURRENTCOL=1
					export totalAvg=0
					export colLength=0
					export truncate=
					while [ $CURRENTCOL -lt $COLS ]; do 
						# add up column averages
						colAvg=$(cut -f $CURRENTCOL -d"$delimiter" $1 | tail -n +2 | awk ' { thislen=length($0); totlen+=thislen} END { printf("%d\n", totlen/NR+8); } ')
						totalAvg=$(($colAvg+$totalAvg))
						#echo "Column #$CURRENTCOL: $colAvg characters, total so far: $totalAvg"
						export colLength="$colLength $colAvg"
					#	truncate[$CURRENTCOL]=$colAvg
						
						((CURRENTCOL++))
					done
					# Handle when totalAvg + COLS exceeds terminal window
					array=( $(echo "$colLength") )
					cat $1  | sed 's/^/CUTMETOO/g' | sed "s/$delimiter/${delimiter}CUTMEOUT/g" | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | while read line; do 
						export i=1
						echo "$line" | tr "$delimiter" '\n' | while read line; do 
						truncateThis=${array[i]}
							# Now we are dealing with each column from a row transposed
							echo "$line" | sed "s/^\(.\{0,$truncateThis\}\).*/\1/" |
							tr '\n' "$delimiter"; 
							((i++))

						done; 
						printf "\n"; 
						i=1
					done | 
					/usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $"$delimiter"
				else 
					# Silly trick to see if bash will be able to use $1 as an integer
					if [ "$3" -eq "$3" ] 2>/dev/null; then
						#INTEGER="y"
						truncate=$(($3+8)) 
					else
						# INTEGER=""
						truncate=100
					fi
					cat $1  | sed 's/^/CUTMETOO/g' | sed "s/$delimiter/${delimiter}CUTMEOUT/g" | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | while read line; do echo "$line" | tr "$delimiter" '\n' | while read line; do echo "$line" | sed "s/^\(.\{0,$truncate\}\).*/\1/"  | tr '\n' "$delimiter"; done; printf "\n"; done | /usr/bin/iconv -t utf-8 -c | /usr/bin/column -ts $"$delimiter"
				fi
			}


			#########################################################################
			# Alternates row background to help organize visually
			# usage:
			#	cat file.txt | alternateRows
			#########################################################################
			alias alternateRows='while read line; do if [ -z "$alternate" ]; then alternate=0; else ((alternate++)); fi; if [ $((alternate%2)) -eq 0 ]; then alternateRow=$(echo -en "\e[48;5;238m\e[38;5;252m"); else alternateRow=$(echo -en "\e[38;5;250m") ; fi; echo "$reset$alternateRow$line$reset"; done'
			#########################################################################
			# Alternates row color (text or background) to help organize visually
			# Usage:
			#	cat file.txt | colorRows
			#	cat file.txt | colorRows x
			#########################################################################
			colorRows() {
			#	BASECOLORS="117 202 106 196 25 201 240 99 22 210 81 203 105"; FULLCOLORS=$(shuf -i 17-240 ); array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; echo " $FULLCOLORS" | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "  ) )
				BASECOLORS="117 202 106 196 25 201 240 99 22 210 81 203 105"; array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; ) )
				if [ -z "$1" ]; then fgbg=38; else fgbg=48; fi
				while read line; do 
					color=${array[z]}
					lastColor=$( echo ${array[${#array[@]}-1]} )
					if [ "$lastColor" == "$color" ]; then 
						array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; ) )
						printf ""
						z=0
					fi
					if [ -z "$alternate" ]; then 
						alternate=0; 
					else 
					((alternate++)); 
					fi; 
					if [ $((alternate%2)) -eq 0 ]; then 
						alternateRow=$(echo -en "\e[38;5;255m\e[${fgbg};5;${color}m");
						((z++)); 
					else 
						alternateRow= #$(echo -en "\e[38;5;255m") ; 
					fi
					echo "$reset$alternateRow$line$reset";
				done
			}
			alias followRows=colorRows
			#########################################################################
			# Takes input from arrange() and grid-ifies it.
			#
			#
			#
			#########################################################################
			makeGrid() {
			#	BASECOLORS="117 202 106 196 25 201 240 99 22 210 81 203 105"; FULLCOLORS=$(shuf -i 17-240 ); array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; echo " $FULLCOLORS" | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "  ) )
				BASECOLORS="117 202 106 196 25 201 240 99 22 210 81 203 105"; array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; ) )
				if [ -z "$1" ]; then fgbg=38; else fgbg=48; fi
				while read line; do
					# Handle colors from above
					color=${array[z]}
					lastColor=$( echo ${array[${#array[@]}-1]} )
					if [ "$lastColor" == "$color" ]; then 
						array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; ) )
						printf ""
						z=0
					fi
					if [ -z "$alternate" ]; then 
						alternate=0; 
					else 
					((alternate++)); 
					fi; 
					if [ $((alternate%2)) -eq 0 ]; then 
						alternateRow=$(echo -en "\e[${fgbg};5;${color}m"); 
						COLOR=`echo -e "\e[48;5;${color}m"`
						NORMAL=`echo -e '\033[0m'`
						griddedLine=$(echo "$line" | sed 's/^CUTMETOO//g' | sed "s/..CUTMEOUT/$NORMAL $COLOR/g" | sed "s/\.\.\.\.\.\.\.\.\././g" ) # sed  "s/\([[:blank:]]\+\)\(.*\)/\1\\\e[48;5;${color}m\2/g" )
						((z++)); 
					else 
						alternateRow= #$(echo -en "\e[38;5;255m") ; 
						griddedLine=$(echo "$line" | sed 's/^CUTMETOO//g' | sed "s/..CUTMEOUT/ /g" | sed "s/\.\.\.\.\.\.\.\.\././g")
					fi
					echo "$reset$alternateRow$griddedLine$reset";
				done
			}
			#########################################################################
			# Like grid, just uncolored
			#
			#
			#
			#########################################################################
			makeBlocks() {
				if [ -z "$1" ]; then fgbg=38; else fgbg=48; fi
				color=238
				textColor=252
				while read line; do 
					if [ -z "$alternate" ]; then 
						alternate=0; 
					else 
					((alternate++)); 
					fi; 
					if [ $((alternate%2)) -eq 0 ]; then 
						alternateRow=$(echo -en "\e[38;5;${textColor}m\e[${fgbg};5;${color}m"); 
						COLOR=`echo -e "\e[38;5;${textColor}m\e[48;5;${color}m"`
						NORMAL=`echo -e '\033[0m'`
						griddedLine=$(echo "$line" | sed 's/^CUTMETOO//g' | sed "s/CUTMEOUT/$NORMAL $COLOR/g" ) # sed  "s/\([[:blank:]]\+\)\(.*\)/\1\\\e[48;5;${color}m\2/g" )
						((z++)); 
					else 
						alternateRow= #$(echo -en "\e[38;5;255m") ; 
						griddedLine=$(echo "$line" | sed 's/^CUTMETOO//g' | sed "s/CUTMEOUT/ /g")
					fi
					echo "$reset$alternateRow$griddedLine$reset";
				done
			}
			#########################################################################
			# This is mostly just used to view things like manifests easier.
			#
			#
			#
			#########################################################################
			organize() {
				# organize file.tsv tab x
				align $1 $2 | followRows x
			}
			alias mani="organize"
		
			#########################################################################
			# This puts the functions from above together.
			# Usage: 
			#	grid file.tsv 'delimiter' 100
			#	where 100 is size to truncate - can be an integer, avg/average of column characters
			#########################################################################
			grid() {
				arrange $1 $2 $3 | makeGrid x
			}
			#########################################################################
			# This is like above, but just grey. Doesn't truncate.
			# Usage:
			#	blocks file.tsv 'delimiter'
			#########################################################################
			blocks() {
				arrange $1 $2 $3 | makeBlocks x
			}

		#########################################################################
		# For tab-separated files, this will look at the top, bottom, highlight line numbers and color the columns.
		#########################################################################
		allTheThings() {
			inspect $1 $2 | highlight stdin LINENUMBERS | /usr/bin/iconv -t utf-8 -c | /usr/bin/columns stdin
		}
		# TO DO: rename lib_
		grabTagStorm() {
			if [ -z "$TAGSTORM" ]; then
				# Let's grab the most recent file that matches the below configuration
				TAGSTORM=$(ls -t *meta* | head -n 1)
				if [ -s "$TAGSTORM" ]; then
					printf ""
				else
					TAGSTORM="help"
				fi
				ASSUMED=1
			fi
		}
		grabManifest() {
			if [ -z "$MANIFEST" ]; then
				# Let's grab the most recent file that matches the below configuration
				MANIFEST=$(ls -t *maniF* | head -n 1)
				if [ -s "$MANIFEST" ]; then
					printf ""
				else
					MANIFEST="help"
				fi
				ASSUMED=1
			fi
		}
		alias emptyTags="grep $'^[[:blank:]]*[a-zA-Z0-9_]\+[[:blank:]]*$'"
		alias removeEmptyTags="grep -v $'^[[:blank:]]*[a-zA-Z0-9_]\+[[:blank:]]*$'"
		
		#########################################################################
		# This collapses a tag storm
		# Usage: listAllTags meta.txt
		#########################################################################
		listAllTags() {
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ listAllTags meta.txt"; return 0; fi
			if [ -s "$1" ]; then
				cat $1 | sed 's/^[[:blank:]]*//g' | cut -f 1 -d " " | cut -f 1 | sort | uniq | awk NF | sed "s/$/ /g"
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		alias listTags=listAllTags
		#########################################################################
		# This parses cdwValid.c and returns a cleaned-up list of tags
		#########################################################################
		listValidTags() {
			cat ~clay/qa/tags.schema | cut -f 1 -d " " | grep -v "^#"
			#	cdwTags=$(grep --no-group-separator -A1000 cdwAllowedTags ~ceisenhart/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",$//g')
			#	misceTags=$(grep --no-group-separator -A1000 misceAllowedTags ~ceisenhart/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",[[:blank:]]*$//g' )
			#	allTags=$( printf "$cdwTags\n$misceTags\n" | sort | uniq)
			#	echo "$allTags" # | sed "s/'//g" | sed "s/^/^[[:blank:]]*/g" | sed "s/$/\\\s/g"
		}
		#########################################################################
		# This collapses a tag storm, then passes it to highlight. Only valid tags are highlighted.
		#########################################################################
		checkTagsValid() {
		#	TO DO: OR GRAB MANIFEST COLUMN
		#	We could run grabTagStorm then:
		#	echo $TAGSTORM
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ listAllTags meta.txt"; return 0; fi
			if [ -s "$1" ]; then
				listAllTags $1 | ~clay/ontogeny/bin/ontogeny_highlight.sh stdin $(listValidTags | sed "s/'//g" | sed "s/^/^[[:blank:]]*/g" | sed "s/$/\\\s/g") | tail -n +5 | sed '$d' | sed '$d'  | sed '$d'
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		

		#########################################################################
		# This just takes the headers from  a tab-separated file and makes them more cdw-compatible.
		# It does not check for validity.
		# usage:
		#	cat meta.tab | convertMisceFields >> misceFields.txt
		# TO DO multiple capital letters in a row don't work.. eg field_ID
		#########################################################################
		alias convertMisceFields=" head -n 1 | sed 's/\S\([A-Z]\)/_\1/g' | sed 's/[^[A-Za-z0-9_\t ]//g' | tr '[[:upper:]]' '[[:lower:]]' | tr ' ' '_' | tr '-' '_' | sed 's/__/_/g' | sed 's/_\t//g' "

		#########################################################################
		# Shows a manifest, and how the meta tags of a tag storm relate to it.
		#########################################################################
		mapToManifest() {
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then printf "Usage:\n	mapToManifest manifest.txt meta.txt\n\nIf no files set, assumes maniFastq.txt and meta.txt\n\nThis will visualize how the meta values from a Tag Storm map into your manifest file.\n\n"; return 0; fi
			if [ -z "$1" ]; then manifest="maniFastq.txt"; else manifest=$1; fi
			if [ -z "$2" ]; then tagStorm="meta.txt"; else tagStorm=$2; fi
			if [ ! -f "$manifest" ]; then templateNotFound $1; return 0; fi
			if [ ! -f "$tagStorm" ]; then templateNotFound $2; return 0; fi
			cat $manifest | ~clay/ontogeny/bin/ontogeny_highlight.sh pipedinput $(grep "meta " $tagStorm | cut -f 2 -d " " | sed "s/^/\t/g" | sed "s/$/\t/g" | sort -r)
		}

		#########################################################################
		# Shows a tag storm, and how the meta column of the manifest relates to it
		#########################################################################
		mapToMeta() {
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then printf "Usage:\n	mapToMeta manifest.txt meta.txt\n\nIf no files set, assumes maniFastq.txt and meta.txt\n\nThis will vizualize how the meta column of your manifest links to your Tag Storm.\n\n"; return 0; fi
			if [ -z "$1" ]; then manifest="maniFastq.txt"; else manifest=$1; fi
			if [ -z "$2" ]; then tagStorm="meta.txt"; else tagStorm=$2; fi
			if [ ! -f "$manifest" ]; then templateNotFound $1; return 0; fi
			if [ ! -f "$tagStorm" ]; then templateNotFound $2; return 0; fi
			metaColumns=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep meta | wc -l)
			if [ "$metaColumns" -gt 1 ]; then echo "There appears to be multiple meta columns in your manifest. We aren't sure which to use."; return 0; fi
			if [ "$metaColumns" -eq 0 ]; then echo "There appears to be no meta column in your manifest."; return 0; fi
			metaColumn=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep meta | sed 's/^[[:blank:]]*//g' | cut -f 1)
			cat $tagStorm | ~clay/ontogeny/bin/ontogeny_highlight.sh pipedinput $(cut -f $metaColumn $manifest | tail -n +2 | sort | uniq)
			# highlight meta.txt $(cut -f 2 maniFastq.txt | tail -n +2 | tr '\n' ' ' | sed 's/ /\\|/g')
		}
		mappingErrors() {
			# Handle help/usage
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then printf "Usage:\n	mappingErrors manifest.txt meta.txt\n\nIf no files set, assumes maniFastq.txt and meta.txt\n\nThis will let you know if any meta values are duplicated, and let you know which ones don't map between the meta and manifest.\n\n"; return 0; fi
			# Automatically choose manifest and meta files if not supplied
			if [ -z "$1" ]; then manifest="maniFastq.txt"; else manifest=$1; fi
			if [ -z "$2" ]; then tagStorm="meta.txt"; else tagStorm=$2; fi
			# Ensure they actually exist
			if [ ! -f "$manifest" ]; then templateNotFound $1; return 0; fi
			if [ ! -f "$tagStorm" ]; then templateNotFound $2; return 0; fi
			# Figure out which column of the manifest links to the tag storm
			metaColumns=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep $'\smeta$' | wc -l)
			if [ "$metaColumns" -gt 1 ]; then echo "There appears to be multiple meta columns in your manifest. We aren't sure which to use."; return 0; fi
			if [ "$metaColumns" -eq 0 ]; then echo "There appears to be no meta column in your manifest."; return 0; fi
			metaColumn=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep $'\smeta$' | sed 's/^[[:blank:]]*//g' | cut -f 1)
			# Before we continue, verify there aren't duplicate "meta" values. We need them to be unique. 
			metaDups=$(cat $2 | grep "meta " | cut -f 2 -d " " | sort | uniq -c | sed 's/^[[:blank:]]*//g' | grep ^2)
			if [ -z "$metaDups" ]; then
				inMeta=$(cat $tagStorm | grep "meta " | cut -f 2 -d  " " | sort | uniq )
				inManifest=$(cut -f $metaColumn $manifest | tail -n +2 | sort | uniq)
				echo "$bg196 Missing from $tagStorm $reset"
				echo
				diff <(echo "$inMeta") <(echo "$inManifest") | grep $'^>' | sed 's/^> //g'
				echo
				echo "$bg196 Missing from $manifest $reset"
				echo
				diff <(echo "$inManifest") <(echo "$inMeta") | grep $'^>'
			else
				echo "$bg196 Duplicate meta values in $tagStorm $reset"
				echo
				echo "	You'll need to resolve these conflicts to continue."
				echo
				echo "$metaDups" | sed 's/^/\t/g'
			fi
			# Output a sed script that matches pattern and can comment out to continue with submission?
			# sed 's/^\(.*$PATTERN.*\)$/#\1/g'
		}

	#################################################################################
	# Ontogeny repository/bin aliases						#
	#################################################################################

		#########################################################################
		# General UNIX software							#
		#########################################################################
		alias columns="$ONTOGENY_INSTALL_PATH/bin/ontogeny_columns.sh"
		alias colorCode="$ONTOGENY_INSTALL_PATH/bin/ontogeny_columnColorizer.sh"
		alias highlight="$ONTOGENY_INSTALL_PATH/bin/ontogeny_highlight.sh"
		alias transfer="$ONTOGENY_INSTALL_PATH/bin/ontogeny_transfer.sh"
		alias changePrompt="source $ONTOGENY_INSTALL_PATH/bin/ontogeny_changePrompt.sh" # This is silly and serves no practical purpose

		#########################################################################
		# General UNIX software - file/directory metrics			#
		#########################################################################
		alias about="$ONTOGENY_INSTALL_PATH/bin/ontogeny_about.sh"
		alias list="$ONTOGENY_INSTALL_PATH/bin/ontogeny_list.sh"
		alias newls="$ONTOGENY_INSTALL_PATH/bin/ontogeny_newLs.sh"
		alias contents="clear; printf \"\n\t$color240\"; pwd; printf \"$reset\"; $ONTOGENY_INSTALL_PATH/bin/ontogeny_contents.sh;"

		#########################################################################
		# Tag Storms								#
		#########################################################################
		alias spreadsheetInput="$ONTOGENY_INSTALL_PATH/bin/ontogeny_spreadsheetInput.sh"
		alias tagStormSummary="$ONTOGENY_INSTALL_PATH/bin/ontogeny_tagStormSummary.sh"
		alias tagSummary="$ONTOGENY_INSTALL_PATH/bin/ontogeny_tagSummary.sh"

		#########################################################################
		# General purpose							#
		#########################################################################
		alias inspectSubmission="$ONTOGENY_INSTALL_PATH/bin/ontogeny_inspectSubmission.sh"
		alias whatHappened=inspectSubmission
		what() { if [[ $@ == "happened" ]]; then whatHappened; fi; }
		alias inspectHere=inspectSubmission
		alias dataSetSummaries="$ONTOGENY_INSTALL_PATH/bin/ontogeny_dataSetSummaries.sh"
		alias dataSetsSummary=dataSetSummaries
		alias dataSetSummary=dataSetSummaries
		alias checkSubmission="$ONTOGENY_INSTALL_PATH/bin/ontogeny_checkSubmission.sh"
		#alias inspectSubmission="$ONTOGENY_INSTALL_PATH/bin/ontogeny_inspectSubmission.sh"
		alias rainbow="$ONTOGENY_INSTALL_PATH/bin/ontogeny_palette.sh"
		alias showColors=rainbow
		alias palette=rainbow

	#################################################################################
	# CIRM-specific stuff								#
	#################################################################################
		
		#########################################################################
		# Submissions								#
		#########################################################################
		lemmeTry() {
			alias cdwSubmitted="hgsql cdw -e \"select distinct(TRIM(LEADING 'local://localhost//data/cirm/wrangle/' FROM url)),MAX(id),MAX(FROM_UNIXTIME(startUploadTime)),wrangler from cdwSubmit where url NOT LIKE 'local://localhost//data/cirm/submit/%' group by url order by id\""
			alias listSubmissions="cdwSubmitted | highlight stdin $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | tr '\n' ' ') |  tail -n +4 | head -n $(cdwSubmitted | wc -l) | columns stdin | tail -n +3 | head -n $(($(cdwSubmitted | wc -l) + 2)); echo $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | sort | uniq | wc -l) data sets and $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | wc -l) submissions."
			alias submitted="hgsql cdw -B -N -e \"SELECT id,TRIM(LEADING 'local://localhost//data/cirm/submit/' from (TRIM(LEADING 'local://localhost//data/cirm/wrangle/' FROM url))),FROM_UNIXTIME(startUploadTime),wrangler,(SELECT count(*) from cdwFile where submitId = cdwSubmit.id and errorMessage IS NOT NULL and errorMessage<>'') FROM cdwSubmit ORDER BY id;\" " #| tail -n +4 | head -n $(( $(submitted | wc -l) - 6 )) "
			alias submissions="submitted | formatted | highlight stdin $(submitted | cut -f 2 | cut -f 1 -d '/' | sort | uniq | tr '\n' ' ') $(submitted | cut -f 4 | sort | uniq | sed 's/$/$/g' | tr '\n' ' '; printf "\$'[1-9]\+[[:digit:]]*\$'") | tail -n +5 | head -n $(submitted | wc -l); echo ; echo $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | sort | uniq | wc -l) data sets and $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | wc -l) submissions."
		}
		#########################################################################
		# Wrangler-curated stuff						#
		#########################################################################
		alias cdwDataSets="hgsql cdw -e 'select id,name,label,description,metaDivTags,metaLabelTags from cdwDataset ORDER BY id asc \G' | GREP_COLOR='00;38;5;107' grep --color=always \$'^[[:blank:]]*name.*\|' | GREP_COLOR='00;38;5;200' grep --color=always \$'^[[:blank:]]*label.*\|' | GREP_COLOR='00;38;5;117' grep --color=always \$'^[[:blank:]]*description.*\|' | GREP_COLOR='00;38;5;202' grep --color=always \$'^[[:blank:]]*metaDivTags.*\|' | GREP_COLOR='00;38;5;25' grep --color=always \$'^[[:blank:]]*metaLabelTags.*\|' | GREP_COLOR='00;38;5;236' grep --color=always \$'^\**.*\|'"
		alias cdwLabs="hgsql cdw -e 'select id,name,pi,institution,url from cdwLab\G' | GREP_COLOR='00;38;5;202' grep --color=always \$'^[[:blank:]]*name.*\|' | GREP_COLOR='00;38;5;200' grep --color=always \$'^[[:blank:]]*institution.*\|' | GREP_COLOR='00;38;5;25' grep --color=always \$'^[[:blank:]]*url.*\|' | GREP_COLOR='00;38;5;117' grep --color=always \$'^[[:blank:]]*pi.*\|' | GREP_COLOR='00;38;5;236' grep --color=always \$'^\**.*\|'"

#########################################################################
# Help messages								#
#########################################################################

	#################################################################
	# grep								#
	#################################################################
		howToGrepColor="$reset $bg25"
		howToGrep() {
			cat << EOF
	
		--------------------------------------------------------------------------------------------------------------------------------------------------------
		From http://proquest.safaribooksonline.com/book/bioinformatics/9781449367480/firstchapter#X2ludGVybmFsX0h0bWxWaWV3P3htbGlkPTk3ODE0NDkzNjc0ODAlMkZjaDA3X2dyZXBfaHRtbCZxdWVyeT1CT09L

		${color25}grep "pattern" ${howToGrepColor}file$reset			# simple search, returns lines with any part that matches pattern
		${color25}grep -v "pattern" ${howToGrepColor}file$reset			# -v excludes lines matching the pattern (in any part of the line)
		${color25}grep -v -w "pattern" ${howToGrepColor}file$reset		# -w matches specific word (surrounded by white space), more restrictive pattern
		${color25}grep -Bn "pattern" ${howToGrepColor}file$reset		# shows context n lines before the match
		${color25}grep -An "pattern" ${howToGrepColor}file$reset		# shows context n lines after the match
		${color25}grep -Cn "pattern" ${howToGrepColor}file$reset		# shows context n lines before and after match
		${color25}grep "pattern[12]" ${howToGrepColor}file$reset 		# matches pattern1 or pattern2
		${color25}grep -E "(pattern1|pattern2)" ${howToGrepColor}file$reset	# -E is POSIX Extended RegEx for more complex matching of multiple patterns, eg. pattern124 vs. pattern 214
		${color25}grep -c "pattern" ${howToGrepColor}file$reset			# count number of lines which match pattern
		${color25}grep -c 'pattern "here"' ${howToGrepColor}file$reset		# grab any lines where "pattern " is followed by "here"
		${color25}grep -o "patt.*" ${howToGrepColor}file$reset			# output only the part of the line that matches, not entire line
		${color25}grep -E -o 'pattern "\w+"' ${howToGrepColor}file$reset	# output only the part of a line where "pattern" is followed by a word

		Example 7-1. Cleaning a set of gene names with Unix data tools

		${color25}$ grep -E -o 'gene_id "(\w+)"' ${howToGrepColor}Mus_musculus.GRCm38.75_chr1.gtf$reset$color25 | \\
		   cut -f2 -d" " | \\
		   sed 's/"//g' | \\
		   sort | \\
		   uniq > mm_gene_id.txt$reset

		Even though it looks complex, this took less than one minute to write (and there are other possible solutions that omit cut, or only use awk). 
		The length of this file (according to wc -l) is 2,027 line long-the same number we get when clicking around Ensembl's BioMart database interface for the same information. 
		In the remaining sections of this chapter, we'll learn these tools so you can employ this type of quick pipeline in your work.
		--------------------------------------------------------------------------------------------------------------------------------------------------------

EOF
		}
		alias howtogrep='howToGrep'

	#################################################################
	# Screen 							#
	#################################################################
		# When you enter a screen, this is a little guide that tells you your screen name and information about it.
		#
		# It also changes your prompt to notify you that you're in a screen.
		#
		# At any time you can type the following for information on screen help:
		#	$ screenHelp
	
		# These act as a timestamp for the .bashrc being loaded
		DATENOW=$(date +"%B %d")
		TIMENOW=$(date +"%R %p")
		# Print a context-sensitive title for screens and screen help
		listScreens() {
			#TO DO
			if [ -n "$STY" ]; then 
				screenMessage=$(printf "\n\tYou are in the screen session $color25$STY$reset"); 
			else 
				#if [ "$WHICHSERVER" == "hgwdev" ] || [ "$WHICHSERVER" == "cirm-01" ]; then
					screenMessage=$(printf "\n\tYour current screen sessions, if any: (when your .bashrc was last sourced $DATENOW at $TIMENOW) $color25\n"; screen -list | sed 's/^/\t\t/g'; printf "$reset"); 
				#fi
			fi
		}
		screenHelp() {
			clear
			listScreens
			cat << EOF
		$screenMessage
	
		You can exit the screen with ${color240}cntrl+a+d$reset. to close a screen permanently, enter the screen and then type$color25 $ exit$reset
		You can see a list of your screens with$color25 $ screen -list$reset
		You can resume a screen with$color25 $ screen -r$color117 123${color240}<tab-complete>$reset
		To create a new screen with a name, use $color25$ screen -S ${color117}sessionName$reset
		To access the screen's scroll buffer, you need to type$color240 cntrl+a+esc$reset, then move the cursor with the arrow keys. to return to the command prompt, hit$color240 esc$reset again.
	
EOF

		}
		alias screenhelp=screenHelp

	#########################################################################
	# Change my prompt							#
	#########################################################################
		# time: \A (or \@ will add AM/PM)
		# current directory: \W
		# server: \h
		# user: \u
		# ansi escape sequence color: \e[38;5;240m (240 can be 0-255)
		# ansi escape sequence reset: \e[0m 
		# to make sure the CLI knows the size, escape with \[ \] or it will be wonky and broken
		if [ -n "$ZSH_VERSION" ]; then
			var=
		elif [ -n "$BASH_VERSION" ]; then
			WHICHSERVER=$(uname -n)
			if [ "$WHICHSERVER" == "hgwdev" ]; then
				export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;107m\]\h \[\e[38;5;240m\]\W/\[\e[0m\] \[\e[m\]\[\e[38;5;25m\]> \[\e[0m\] '
			else
				export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;166m\]\h \[\e[m\]\[\e[38;5;240m\]\W/\[\e[0m\]\[\e[m\] \[\e[m\]\[\e[38;5;25m\]> \[\e[0m\] '
			fi
		else
			var=
		fi

		#########################################################################
		# MySQL prompt too
		#########################################################################
		export MYSQL_PS1="mysql \u@\h \R:\m [\d] > "


		#########################################################################
		# Change behavior when joining a screen					#
		#########################################################################
		if [ -n "$STY" ]; then 
			export PS1="[screen] $PS1"; 
			screenHelp
		fi

		#########################################################################
		# Template for a function
		# o - accept multiple (unlimited) files
		# o - parses multiple (unlimited) arguments 
		# o - assigns different colors to each argument, with the first 6 and then 13 colors curated for visibility
		#########################################################################
		# Usage:
		# 	allTheArguments "$(ls *.txt)"  arg1 arg2 arg3 arg4
		allTheArguments() {
			echo
			wall
			# First arg is the file, so let's just grab args after that
			ARGS=$(for f in $@; do echo "${f}"; done | tail -n +2)
			# Sometimes multiple files are used, so we need to account for that
			FILENUM=$(for f in $1; do echo "${f}"; done | wc -l | cut -f 1 -d " ")
			# We know that we will be off by at least one argument, because the first arg is the file.
			OFFSET=$((1+FILENUM))
			# This will give us a straight list of our arguments separated from the files
			ARGTERMS=$(for f in $@; do echo "${f}"; done | tail -n +$OFFSET)
			# Convert the argument terms to a number
			ARGTERMNUM=$(echo "$ARGTERMS" | wc -l)
			#########################################################################
			# Let's start with very different colors to maintain contrast between matches
			#########################################################################
			NEEDEDCOLORS=$((ARGTERMNUM-12))
			BASECOLORS="117 202 106 196 25 201"
			# This will extend the colors. This way we avoid colors too similar if only a few search terms, but have a lot of colo variety with many search terms
			EXTENDEDCOLORS="240 99 22 210 81 203 105"
			if [ "$ARGTERMNUM" -lt "7" ]; then
				array=( $(echo "$BASECOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
			elif [ "$ARGTERMNUM" -lt "14" ] && [ "$ARGTERMNUM" -gt "6" ]; then
				array=( $(echo "$BASECOLORS $EXTENDEDCOLORS" | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
			else
				FULLCOLORS=$(shuf -i 17-240 -n $NEEDEDCOLORS)
				array=( $(printf "$BASECOLORS $EXTENDEDCOLORS " | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " "; echo " $FULLCOLORS" | tr '\n' ' ' | sed -r 's/(.[^;]*;)/ \1 /g' | tr " " "\n" | shuf | tr -d " " ) )
			fi
			echo $WALL
			echo "File(s):	$color240$(echo $1 | tr ' ' ',\s' | sed 's/,$//g' )$reset"
			echo "Arguments: $color240$ARGTERMNUM$reset"
			echo $WALL
			i=0
			argnum=1
			for f in $ARGTERMS; do 
				color=${array[i]}
				printf "\e[38;5;${color}m$argnum: $f$reset\n"
				((argnum++))
				((i++))
			done
			echo $WALL
			echo
		}
		#########################################################################
		# Template to accept flags in a function
		# o - be sure to unset any variables and flags needed, or assign them under 'local'
		# o - set your flags on the while loop
		# o - shows help with incorrect usage
		#########################################################################
		# Usage:
		# 	functionFlags -a "Let's see" -b "Another thing"
		functionFlags() {
			get_help() { echo "usage: command -a <arg> -b <arg>" 1>&2; }
			# Set your flags as local or they may inherit values from calling itself multiple times
			local OPTIND f a b flagVar2
			# Set getopts flags you'll allow. If the flag requires an argument, follow it with a colon
			while getopts ":a:b:" f; do
				case "${f}" in
					a)	a=$OPTARG
						;;
					b)	if [ -n "$OPTARG" ]; then
							flagVar2=$OPTARG
						fi
						;;
					*)	get_help >&2
						echo "	non-option arguments: $*"
						return 0
						;;
				esac
			done
			if [ -n "$a" ]; then
				echo "Hello, world!"
			fi
			shift $((OPTIND-1))
			echo
			echo "Here's what you set:"
			echo "	a: $a"
			echo "	b: $flagVar2"
			echo 
		}

		# For trawling for lab_ tags
		alias raiseTags="hgsql cdw -e \"describe cdwFileTags;\" | grep lab_ | cut -f 1 | sed 's/lab_[[:alnum:]]*_//g' | sort | uniq -c | grep ^[[:blank:]]*2"
		tagTrawl() {
			if [ "$1" == "" ]; then printf "Grabs random values from lab_ tabs and puts into file.txt to see if they should be raised. Then can use with highlightTrawl.\nUsage:\n\ttagTrawl file.txt\n"; return 0; fi
			
			hgsql cdw -e "describe cdwFileTags" | grep lab_ | cut -f 1 | while read line; do hgsql cdw -e "select distinct($line) from cdwFileTags ORDER BY RAND() LIMIT 5"; done > $1
		}

		highlightTrawl() {
			# TO DO: make a function that will organize highlight contents as STARTpatternEOL
			if [ "$1" == "" ]; then printf "Highlights values from a tagTrawl file.\nUsage:\n\thighlightTrawl file.txt\n"; return 0; fi
			highlight $1 $(cat duplicateTagValues.txt | sort | uniq -c | grep ^[[:blank:]]*2 | sed 's/^[[:blank:]]*[^1] //g' | grep -v ^[0-9]*$ | sed 's/\s/\\s/g' | sed 's/^/^/g' | sed 's/$/$/g' ) | sed 's/^/\t/g' | sed 's/^\tlab_/lab_/g'
		}

		whichDataSetTagBelongsTo() {
			if [ "$1" == "" ]; then printf "whichDataSetTagBelongsTo tag_to_look_for\n"; return 0; fi
			hgsql cdw -N -e "select distinct(data_set_id) from cdwFileTags where $1<>''"
		}


		grabDistinctTagValues() {
			if [ "$1" == "" ]; then printf "grabDistinctTagValues tag_to_look_for\n"; return 0; fi
			hgsql cdw -e "select distinct($1),data_set_id from cdwFileTags WHERE $1 IS NOT NULL;"
		}
		tagValues() {
			# Usage:
			#	
			COMMAND=""
			if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "tagValues tag_1 tag_2 ... tag_n\n"; return 0; fi
			numArgs=$(echo "$@" | tr ' ' '\n' | wc -l)
			for x in $@; do 
				COMMAND="$COMMAND hgsql cdw -e \"select distinct($x) from cdwFileTags ORDER BY RAND() LIMIT 50;\";" 
				#COMMAND="$COMMAND hgsql cdw -N -e \"select distinct($x),data_set_id,(SELECT count(distinct(data_set_id)) from cdwFileTags where $x = cdwFileTags.$x ) as numDataSets from cdwFileTags WHERE $x in (select data_set_id from cdwFileTags where $x = cdwFileTags.$x) \";"
				#COMMAND="$COMMAND hgsql cdw -N -e \"select distinct(\$x) from cdwFileTags WHERE \$x IS NOT NULL ORDER BY RAND() LIMIT 100\" | while read line; do printf \"\$line\t\"; hgsql cdw -N -e \"select distinct(data_set_id) from cdwFileTags where \$x = '\$line';\" | tr '\n' ' '; printf '\n'; done;"
			done
			eval "$COMMAND"
		}
		tagStructure() {
			if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "tagStructure file.txt\n"; return 0; fi
			cat $1 | sed 's/^\([[:blank:]]*[a-zA-Z0-9_]\+[[:blank:]]\).*$/\1/g' #sed 's/^\([[:blank:]]*.\+ \).*$/\1/g'
		}

		tagStormSkeleton() {
			if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "tagStormSkeleton file.txt\n"; return 0; fi
			cat $1 | sed 's/^\([[:blank:]]*[a-zA-Z0-9_]\+[[:blank:]]\).*$/\1/g' | awk '!x[$0]++' | awk NF
		}

		tagStormDiv() {
			if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "tagStormDiv file.txt\n"; return 0; fi
			cat $1 | sed 's/^\([[:blank:]]*[a-zA-Z0-9_]\+[[:blank:]]\).*$/\1/g' | nl --body-numbering=a | sort -uk2 | sort -nk1 | cut -f2- | awk NF
		}

		checkAllTagStorms() {
			ls /data/cirm/wrangle/*/meta.txt | while read line; do printf "\n\e[48;5;25m $(echo $line | cut -f 5 -d "/") \e[0m\n"; tagStormCheck /data/cirm/valData/meta.schema $line; done
		}
		checkAllCv() {
			ls /data/cirm/wrangle/*/meta.txt | while read line; do printf "\n\e[48;5;25m $(echo $line | cut -f 5 -d "/") \e[0m\n"; ~kent/bin/x86_64/tagStormCheck ~clay/qa/cv.schema $line; done
			printf "\n\nTag schema updated from the tagsv5.xlsx spreadsheet at $color25$(ls -lph --time-style="+%I:%M %p, %a %b %d, %Y" ~clay/qa/cv.schema | cut -f 6-11 -d " ")$reset\n\n" 
		} 
		checkAllTags() {
			ls /data/cirm/wrangle/*/meta.txt | while read line; do printf "\n\e[48;5;201m $(echo $line | cut -f 5 -d "/") \e[0m\n"; ~kent/bin/x86_64/tagStormCheck ~clay/qa/tags.schema $line; done
			printf "\n\nTag schema updated from the tagsv5.xlsx spreadsheet at $color25$(ls -lph --time-style="+%I:%M %p, %a %b %d, %Y" ~clay/qa/tags.schema | cut -f 6-11 -d " ")$reset\n\n" 
		} 
		fixDates(){
			if [ -z "$2" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "Fixes dates in the MM/DD/YYYY, MM-DD-YYYY or MM_DD_YYYY format to YYYY-MM-DD. \nDoes not write to file. Output to a new file and run a diff.\n\n\tfixDates file.txt tag_to_fix > file2.txt\n\tdiff file.txt file2.txt\n\n"; return 0; fi
			# sed "s/submission_date \([[:digit:]]\+\)[-_/]\([[:digit:]]\+\)[-_/]\([[:digit:]]\+\)/submission_date \3-\1-\2/g" meta.txt
			#sed "s/$2 \([[:digit:]]\+\)[_-/]\([[:digit:]]\+\)[-_/]\([[:digit:]]\+\)/$2 \3-\1-\2/g" $1
			sed "s/$2 \([[:digit:]]\+\)[-_/]\([[:digit:]]\+\)[-_/]\([[:digit:]]\{4\}\)/$2 \3-\1-\2/g" $1
		}
updateSchema() {
	#dirs -c
	#printf "${color240}Current dir:$reset\t\t\t\t"
	#pushd .
	printf "${color240}Copying schema:$reset\t\t\t\t"
	cp /data/cirm/valData/meta.schema ~clay/ontogeny/cirm && printf "$bg25 done $reset\n"
	printf "${color240}Changing to repository directory:$reset\t"
	cd ~clay/ontogeny/cirm && printf "$bg25 done $reset\n"
	printf "${color240}Adding to git:$reset\t\t\t\t"
	git add meta.schema && printf "$bg25 done $reset\n"
	printf "${color240}git status (if any):$reset\n"
	git diff --stat --cached origin/master
	#printf "${color240}Returning to previous directory$reset\t\t"
	#popd | sed 's/\n//g' | sed 's/\n//g' | sed 's/\n//g' &&  printf "$bg25 done $reset\n\n"
}

cleanUpGspreadCells() {
#	tr ',' '\n' | sed "s/^[ \[]<Cell R[[:digit:]]*C[[:digit:]]* '//g" | sed "s/'>$//g" | sed "s/'>]//g" | awk NF
#	tr ',' '\n' | sed "s/^[ \[]<Cell R[[:digit:]]*C[[:digit:]]* '/'/g" | sed "s/'>$/'/g" | sed "s/'>]//g" | sed "s/''//g" | sed "s/'\([$%#]\)'/\1/g" | awk NF
	tr ',' '\n' | cut -f 2 -d "'" | sed "s/'\([$%#]\)'/\1/g"
}
cleanUpGspreadSheetList() {
	sed 's/,/\n/g' | sed "s/^.*'\(.*\)'.*$/\1/g"
}

cleanSimpleDiff() {
	grep $'^[<>\d]' | sed 's/^[<>][[:blank:]]*//g' | sed '$!N;s/\n/\t>\t/' | formatted
}
cleanDiff() {
	#grep $'^[<>\d]' | sed 's/^[<>][[:blank:]]*//g' | sed '$!N;s/\n/\t>\t/' | formatted
	sed 's/[[:blank:]]*\([|<>]\)[[:blank:]]*/\t\1\t/g' | sed 's/^[[:blank:]]*\([^|<>]\)/\1/g' | formatted
}

checkCv() {
	tagStormCheck ~clay/qa/cv.txt $1
}


STAMP=$(echo $(date +"%B_%d.%I_%M%p") | tr '[:upper:]' '[:lower:]' )


LONGESTLINE() {
	awk -F"\t" 'BEGIN{b=0}{for(i=1;i<=NF;i++){a=length($i);if(a>b)b=a;}}END{print b}'
}

columnate() {
			[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"
			cat $input
#	lib_detectStdin || return 1
	if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then printf "A more robust version of the UNIX built-in column (which cannot handle non-ASCII).\n\tcolumnate file.txt\n"; return 0; fi
	if [ $# -lt 1 ]; then 
		cat
	else
		cat "$*"
	fi | 
	cols=$(awk -F'\t' '{for (i=1; i<=NF; i++) max[i]=(length($i)>max[i]?length($i):max[i])} END {for (i=1; i<=NF; i++) printf "%d%s", max[i], (i==NF?RS:FS)}' $1)
	i=1
	colIndex=
	colWidths=
	for col in $cols; do
		((col++))
		((col++))
		colWidths="$colWidths %-${col}s"
		colIndex="$colIndex \$$i,"
		((i++))
	done
	colWidths=$(echo "$colWidths" | sed 's/$/\\n/g' | sed 's/^ //g') 
	colIndex=$(echo "$colIndex" | sed 's/,$//g')
	COMMAND="awk -F'\t' '{printf \"$colWidths\", $colIndex}'"
	eval "cat - $1 | awk NF | $COMMAND"
}

sideDiff() {

	sdiff -w$COLUMNS $1 $2
}

#
handleStdinA () {
    if read -t 0; then
        cat
    else
        echo "$*"
    fi #| while read line; do echo $line; done
}


jc_hms() { 
  declare -i i=${1:-$(</dev/stdin)};
  declare hr=$(($i/3600)) min=$(($i/60%60)) sec=$(($i%60));
  printf "%02d:%02d:%02d\n" $hr $min $sec;
}

testStdinA() {

	cat | sed 's/^/\t/g'
	
}

testStdinB() {

	while read stdin; do
		echo "$stdin"
	done | sed 's/^/\t/g'
	
}

testStdinC() {

  declare -i i=${1:-$(</dev/stdin)};
	echo "$i" | sed 's/^/\t/g'
}


testStdinD() {
    if read -t 0; then
        cat
    else
        echo "$*"
    fi
}


highlightValidTags() {
	hgsql cdw -Ne "describe cdwFileTags" | cut -f 1 | highlight piped $(cut -f 1 -d  " " ~clay/qa/tags.schema | sed "s/^/^/g" | sed "s/$/$/g")
}

convertToCsv() {
	cat | sed 's/$/, /g' | tr '\n' ' ' | sed 's/, $//g'; printf "\n"
}



curateTags() {

	if [ "$1" = "" ]; then export LIMIT=10; else export LIMIT=$1; fi
	#TAG=`echo -e "\e[38;5;$(( ( RANDOM % 255 )  + 1 ))m"`
	#VALUE=`echo -e "\e[38;5;25m"`
	NORMAL=`echo -e '\033[0m'`
	hgsql cdw -Ne "describe cdwFileTags" | cut -f 1 | grep -v $'accession\|^map_\|^vcf_\|^enrichment_\|^chrom\|^submit_\|^paired_end_\|^sorted_by\|^valid_key\|^file_size\|^read_size\|^seq_depth\|^sample_name\|^geo_\|^GEO_\|^md5' | while read line; do hgsql cdw -Ne "select distinct($line) from cdwFileTags WHERE $line IS NOT NULL ORDER BY RAND() limit $LIMIT" | while read line2; do echo "$line $line2"; done; done > all.tags
	tagStormCheck -maxErr=5000 ~clay/qa/tags.schema all.tags &> issues.tags
	cat issues.tags | grep ^Unrecognized | while read line; do TAG=`echo -e "\e[38;5;$(( ( RANDOM % 255 )  + 1 ))m"`; echo $line | sed "s/'\(.*\)'/$TAG\1$NORMAL/g" | sed "s/tagsss \(.*\)$/tag $TAG\1$NORMAL/g"; done | highlight piped  $( cat issues.tags | grep ^Unrec | rev | cut -f 1 -d " " | rev | sort | uniq )
}


curateTagList() {

	# along these QA lines, what about checking that file format and file output are always the same? eg. look for all output where format = vcf. They should be the same. How to check for diffs in capitalization? maybe
	# use bash?


	if [ "$1" = "" ]; then export LIMIT=10; else export LIMIT=$1; fi
	#TAG=`echo -e "\e[38;5;$(( ( RANDOM % 255 )  + 1 ))m"`
	#VALUE=`echo -e "\e[38;5;25m"`
#	NORMAL=`echo -e '\033[0m'`
	hgsql cdw -Ne "describe cdwFileTags" | cut -f 1 | grep -v $'accession\|^map_\|^vcf_\|^enrichment_\|^chrom\|^submit_\|^paired_end_\|^sorted_by\|^valid_key\|^file_size\|^read_size\|^seq_depth\|^sample_name\|^geo_\|^GEO_\|^md5' | while read line; do hgsql cdw -Ne "select distinct($line) from cdwFileTags WHERE $line IS NOT NULL ORDER BY RAND() limit $LIMIT" | while read line2; do echo "$line $line2"; done; done > all.tags
	tagStormCheck -maxErr=5000 ~clay/qa/tags.schema all.tags &> issues.tags
	cat issues.tags | grep ^Unrecognized | rev | cut -f 1 -d " " | rev | sort | uniq | while read line; do printf "\n$color25$line$reset\n"; grep $line issues.tags | cut -f 2 -d "'" | sed 's/^/\t/g'; done
}

cdwGroupUsers() {
hgsql cdw -e "select userId,(SELECT email from cdwUser where id = cdwGroupUser.userId) as email,groupId,(SELECT name from cdwGroup where id = cdwGroupUser.groupId) as lab_group from cdwGroupUser ORDER BY userId"

}

nonUniqueMeta() {
	list=$(cat $1 | grep "meta " | cut -f 2 -d " " | sort | uniq -c | sed 's/^[[:blank:]]*//g' | grep ^2)
	if [ -z "$list" ]; then
		echo "$bg107 PASS $reset"
	else
		echo "$bg196 FAIL $reset"
		echo "$list" | sed 's/[[:blank:]]\+/\t/g'
	fi | awk NF
}

