#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_toolkit.sh
#################################################################################

	#################################################################################
	# Purpose									#
	#################################################################################
	# This extends a user's .bashrc to take advantage of ontogeny tools and provide
	# aliases to the shell scripts and UNIX command-line tools useful when dealing
	# with big data.

	#################################################################################
	# Install									#
	#################################################################################
	# To use it, source it from your .bashrc and assign the variable ONTOGENY_INSTALL_PATH.
	# For example, in your .bashrc file add the following:
	# 	ONTOGENY_INSTALL_PATH=/home/user/tim/ontogeny
	# 	source $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh

	#################################################################################
	# Config									#
	#################################################################################
	# Edit this to what you want. I like a lot of history.
	export HISTSIZE=5000
	# I edit my .bashrc often enough that this is useful to me.
	alias load='source ~/.bashrc; source ~/.bash_profile'
	alias bashrc='vi ~/.bashrc'
	alias ontogeny_toolkit='vi $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh'

	# Some of my commonly-used background colors:
	bg25=$(echo -en "\e[48;5;25m")
	bg107=$(echo -en "\e[48;5;107m")
	bg117=$(echo -en "\e[48;5;117m")
	bg196=$(echo -en "\e[48;5;196m")
	bg202=$(echo -en "\e[48;5;202m")
	bg240=$(echo -en "\e[48;5;240m")
	# Some of my commonly-used foreground colors:
	color25=$(echo -en "\e[38;5;25m")
	color107=$(echo -en "\e[38;5;107m")
	color117=$(echo -en "\e[38;5;117m")
	color196=$(echo -en "\e[38;5;196m")
	color202=$(echo -en "\e[38;5;202m")
	color240=$(echo -en "\e[38;5;240m")
	#
	reset=$(echo -en "\e[0m")

	# Setting LANG to anything other than 'C' may affect sort behavior. 
	# To fix, either 1) set everything =C, 2) LC_COLLATE=C LC_ALL=C after LANG if you insist on using it 3) or sort +0 -1
	# I set LC_ALL at the end which seems to make my sort work as anticipated.
	export TERM=xterm-256color
	export LANG="en_US.UTF-8"
	export LESSCHARSET=utf-8
	export LC_ALL=C

	#################################################################################
	# General UNIX/Linux tools							#
	#################################################################################

		#########################################################################
		# UNIX/linux aliases							#
		#########################################################################
		alias l="ls -lph"
		alias lf="ls -lph | egrep -v '^d'"
		alias ldir="ls -lph | egrep '^d' | GREP_COLORS='mt=38;5;25' grep --color=always -P '\S+\/$|'"

		#########################################################################
		# Screen formatting							#
		#########################################################################
		alias noWrap='tput rmam; { sleep 20 && tput smam & };'

		#########################################################################
		# ascii									#
		#########################################################################
		# usage:
		#	cat file.txt | ascii
		#	cat file.txt | nonascii
		alias nonascii=' GREP_COLOR="00;48;5;107" LC_CTYPE=C grep --color=always -n -P "[\x80-\xFF]"  | sed "s/:/\t/g" | while read line; do printf "\n"; echo "$line" | fmt -w 150 | sed -e "1s/^/ /" -e '\''2,$s/^/\t/'\''; done  | sed "s/^/\t/" | sed "1s/^/\n\t $bg107 non-ascii characters $reset $bg240 in context $reset\n/"; printf "\n\n"'
		alias    ascii=' GREP_COLOR="00;48;5;202" LC_CTYPE=C grep -n -P -o ".{0,40}[\x80-\xFF].{0,40}" | sed "s/:/\t/g" | sed "s/^/\t/" | GREP_COLOR="00;48;5;202" LC_CTYPE=C grep --color=always -P "[\x80-\xFF]" | sed "1s/^/\n\t$bg202 non-ascii characters $reset $bg240 trimmed from context $reset\n\n/"; printf "\n\n"'

		#########################################################################
		# If you need a quick folder, don't use foo or temp...			#
		#########################################################################
		# alias mkdirtoday='mkdir $(date +%F & "-" & echo $RANDOM)'
		# date +"%H%M%S" vs. date +%R
 		alias mkdirRand='mkdir "$(date +%F)-$RANDOM"'
		alias mkdirNow='mkdir "$(date +%F)-$(date +"%H_%M_%S")"'
		alias mkdirTime='mkdir "$(date +"%H_%M_%S")"'
		alias foo='mkdir "$(date +"%b_%d")_$(date +"%I_%M_%p")"'

		#########################################################################
		# Directory/text file inspection/summary				#
		#########################################################################
		# As this takes time to execute du, I would not rely on its accuracy, just as a way of knowing something is being written.:
		alias writing='echo ""; echo "$(( ($(du  --apparent-size -s | cut -f 1) - $(sleep 1; du --apparent-size -s | cut -f 1)) / -1 | bc -l  )) bytes written in the last second in $PWD"; printf "\n\n"'
		# Usage: 
		# 	$ cat file.txt | format
		alias format=" sed 's/\t\t/\t\.\t/g' |  sed 's/\t$/\t\./g' | column -ts $'\t' "
		alias linesNotEmpty='grep -c "[^ \\n\\t]"'
		alias linesContent='grep -v "^#" | grep -c "[^ \\n\\t]"'
		alias numColumns="awk -F '\t' '{print NF; exit}'"
		alias whichColumn="awk -F'\t' ' { for (i = 1; i <= NF; ++i) print i, \$i; exit } ' "
		# Shows column numbers with header and example row. Usage:
		# 	cat file.txt | whichColumns
		alias whichColumns=" head -n 2 | awk -F'\t' '{ for (i = 1; i <= NF; i++) f[i] = f[i] \"     \t\" \$i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^ */, \"\", f[i]) ; for (i = 1; i <= n; i++) print i, f[i] } ' | column -ts $'\t'"
		# This will show where you have tabs and multiple spaces. Usage: 
		#	cat file.txt | cleanUp
		alias cleanUp=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;117' grep --color=always -e \$'\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg117 tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		alias cleanUpToo=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;107' grep --color=always -e \$'\t\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg107 multiple tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		# This is for files that sometimes don't have a newline on the last line... it messes things up...
		alias fixLastLine="sed -e '\$a\'"
		alias fixCLFR="sed -e 's/[\\r\\n]//g'"
		alias fixNewLines=fixCLFR
		#########################################################################
		# Make a custom border							#
		#########################################################################
		border=1
		WALL=
		WINDOW=$(tput cols)
		while [ "$border" -lt "$WINDOW" ]; do
			WALL="=$WALL";
			((border++))
		done
		WALL="$color240$WALL$reset"
		#########################################################################
		# This is a way of looking at the top and bottom of a file.
		#########################################################################
		headAndTail() {
			if [ -s "$1" ]; then
				BIGENOUGH=$(wc -l $1 | cut -f 1 -d " ")
				if [ -z "$2" ]; then PREVIEWLINES=5; else PREVIEWLINES=$2; fi
				if [ "$BIGENOUGH" -gt "20" ]; then
					(echo "$WALL"; head -n $PREVIEWLINES; echo $WALL; nl --body-numbering=a  | sed 's/^\([[:blank:]]*[[:digit:]]\+\)\t/\1 /g' | tail -n $PREVIEWLINES; echo $WALL) < $1 
				else
					echo "This file is too small to inspect the head and tail."
				fi
			else
				echo "Please provide a filename that exists and has content."
			fi
		}

		alias inspect=headAndTail
		#########################################################################
		# For tab-separated files, this will look at the top, bottom, highlight line numbers and color the columns.
		#########################################################################
		allTheThings() {
			inspect $1 $2 | highlight stdin LINENUMBERS | columns stdin
		}

		#########################################################################
		# This is useful for looking for chunks that match a pattern, eg. 	#
		# errors in a log file.	Gives you nicely formatted output.		#
		#########################################################################
		showMatches() {
			# showMatches file.txt pattern [10]
			DIVISIONBORDER="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
			if [ -z "$3" ]; then NUMBER=5; else NUMBER=$3; fi
			# cat test.txt | nl | sed 's/\(.*before*.\)/=======\n\1/g' | grep -A10 =======
			cat $1 | nl | sed "s/\(.*$2*.\)/$DIVISIONBORDER\n\1/g" | grep --no-group-separator -A$NUMBER "$DIVISIONBORDER"
		}

	#################################################################################
	# Ontogeny repository/bin aliases						#
	#################################################################################

		#########################################################################
		# General UNIX software							#
		#########################################################################
		alias columns="$ONTOGENY_INSTALL_PATH/bin/ontogeny_columns.sh"
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
		alias checkSubmission="$ONTOGENY_INSTALL_PATH/bin/ontogeny_checkSubmission.sh"

	#########################################################################
	# umask line added to allow groups to write to created directories	#
	#########################################################################
	umask 002

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
		if [ -n "$STY" ]; then 
			screenMessage=$(printf "\n\n\tYou are in the screen session $color25$STY$reset"); 
		else 
			screenMessage=$(printf "\n\n\tYour current screen sessions, if any: (when your .bashrc was last sourced $DATENOW at $TIMENOW) $color25\n"; screen -list | sed 's/^/\t\t/g'; printf "$reset"); 
		fi
		screenHelp() {
			cat << EOF
		$screenMessage
	
		Quick refresher:

		You can exit the screen with ${color240}cntrl+a+d$reset. to close a screen permanently, enter the screen and then type$color25 $ exit$reset
		You can see a list of your screens with$color25 $ screen -list$reset
		You can resume a screen with$color25 $ screen -r$color117 123${color240}<tab-complete>$reset
		To create a new screen with a name, use $color25$ screen -S ${color117}sessionName$reset
		To access the screen's scroll buffer, you need to type$color240 cntrl+a+esc$reset, then move the cursor with the arrow keys. to return to the command prompt, hit$color240 esc$reset again.
	
EOF

		}


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
		WHICHSERVER=$(uname -n)
		if [ "$WHICHSERVER" == "hgwdev" ]; then
			export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;107m\]\h \[\e[38;5;240m\]\W/\[\e[0m\] 🌀 \[\e[0m\] '
			export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;107m\]\h \[\e[38;5;240m\]\W/\[\e[0m\] \[\e[m\]\[\e[38;5;25m\]> \[\e[0m\] '
		else
			export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;166m\]\h \[\e[38;5;240m\]\W/\[\e[0m\]⚡   \[\e[0m\] '
			export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;166m\]\h \[\e[m\]\[\e[38;5;240m\]\W/\[\e[0m\]\[\e[m\] \[\e[m\]\[\e[38;5;25m\]⚡  \[\e[0m\] '
			export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;166m\]\h \[\e[m\]\[\e[38;5;240m\]\W/\[\e[0m\]\[\e[m\] \[\e[m\]\[\e[38;5;25m\]> \[\e[0m\] '
		fi

		#########################################################################
		# Change behavior when joining a screen					#
		#########################################################################
		if [ -n "$STY" ]; then 
			export PS1="[screen] $PS1"; 
			screenHelp
		fi


