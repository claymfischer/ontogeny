
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
	#
	# The things most users would wnat to change are at the top (except the PS1 variable near the bottom)

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
	# Edit this to what you want. I like a lot of history, and this makes it act sorta like mosh...
	unset HISTFILESIZE
	HISTSIZE=5000
	PROMPT_COMMAND="history -a"
	export HISTSIZE PROMPT_COMMAND
	shopt -s histappend
	
	# I edit my .bashrc often enough that this is useful to me.
	alias load='source ~/.bashrc; source ~/.bash_profile'
	alias bashrc='vi ~/.bashrc'
	alias ontogeny_toolkit='vi $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh'

	# Some of my commonly-used background colors:
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
	#
	reset=$(echo -en "\e[0m")

	# Setting LANG to anything other than 'C' may affect sort behavior. 
	# To fix, either 1) set everything =C, 2) LC_COLLATE=C LC_ALL=C after LANG if you insist on using it 3) or sort +0 -1
	# I set LC_ALL at the end which seems to make my sort work as anticipated.
	export TERM=xterm-256color
	export LANG="en_US.UTF-8"
	export LESSCHARSET=utf-8
	export LC_ALL=C

	#########################################################################
	# umask line added to allow groups to write to created directories	#
	#########################################################################
	umask 002

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
		# Screen formatting (temporary)						#
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
		# This will show where you have tabs and multiple spaces. Usage: 
		#	cat file.txt | cleanUp
		# GREP_COLOR='00;48;5;201' grep --color=always -e $'\t$' -e ''
		alias cleanUp=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;117' grep --color=always -e \$'\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg117 tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		alias cleanUpToo=" GREP_COLOR='00;48;5;202' grep --color=always -E '  |' | GREP_COLOR='00;48;5;107' grep --color=always -e \$'\t\t' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg107 multiple tabs $reset $bg202 multiple spaces $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		alias cleanUpEnds="GREP_COLOR='00;48;5;117' grep --color=always -e \$' \$' -e '' |   GREP_COLOR='00;48;5;201' grep --color=always -e \$'\t\$' -e '' | grep -n '' | sed 's/^\([[:digit:]]*\):/\t\1\t/g' | sed '1s/^/\n\t$bg201 tab line endings $reset $bg117 space line endings $reset $reset\n\n/' | sed -e \"\\\$a\\ \""
		# This is for files that sometimes don't have a newline on the last line... it messes things up...
		alias fixLastLine="sed -e '\$a\'"
		# Data from Windows or some rich text will have lines end with both a carriage return and newline character, this fixes it.
		alias fixCLFR="sed -e 's/[\\r\\n]//g'"
		alias fixNewLines=fixCLFR
		alias deleteBlankLines="sed '/^\s*$/d' "

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
		#alias format="  sed 's/\t\t/\t\.\t/g' | sed 's/.\t\t/.\t.\t/g' | sed 's/\t$/\t\./g' | column -ts $'\t' "
		alias format="sed 's/\t\t/\t.\t/g' | sed 's/.\t\t/.\t.\t/g' | sed 's/\t$/\t./g' | sed 's/.\t$/\t./g' | sed 's/^\t/.\t/g' | column -ts $'\t' | sed '1s/^/\n$WALL\n/'; printf '$WALL\n\n'"
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
			if [ -z "$2" ]; then 
				delimiter=$'\t'
				aligningOn="tab"
			else
				delimiter=$2
				aligningOn=$2
			fi
			echo 
			echo "${color240}Aligned with $reset$bg25 $aligningOn $reset ${color240}as delimiter.$reset"
			echo "$WALL" 
			cat $1 | sed "s/$delimiter$delimiter/$delimiter.$delimiter/g" | sed "s/.$delimiter$delimiter/.$delimiter.$delimiter/g" | sed "s/$delimiter$/$delimiter./g" | sed "s/.$delimiter$/$delimiter./g" | sed "s/^$delimiter/.$delimiter/g" | column -ts $"$delimiter"
			#cat $1 | sed "s/$2$2/$2.$2/g" | sed "s/.$2$2/.$2.$2/g" | sed "s/$2$/$2./g" | sed "s/.$2$/$2./g" | sed "s/^$2/.$2/g" | column -ts $"$2"
			echo "$WALL"
		}
		alias linesNotEmpty='grep -c "[^ \\n\\t]"'
		alias linesContent='grep -v "^#" | grep -c "[^ \\n\\t]"'
		alias numColumns="awk -F '\t' '{print NF; exit}'"
		alias whichColumn="awk -F'\t' ' { for (i = 1; i <= NF; ++i) print i, \$i; exit } ' "
		# Shows column numbers with header and example row. Usage:
		# 	cat file.txt | whichColumns
		alias whichColumns=" head -n 2 | awk -F'\t' '{ for (i = 1; i <= NF; i++) f[i] = f[i] \"     \t\" \$i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^ */, \"\", f[i]) ; for (i = 1; i <= n; i++) print i, f[i] } ' | column -ts $'\t'"
		describeColumns() {
			head -n 2 $1 | awk -F'\t' '{ for (i = 1; i <= NF; i++) f[i] = f[i] "     \t" $i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^ */, "", f[i]) ; for (i = 1; i <= n; i++) print i, f[i] } ' | column -ts $'\t'
		}
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
			export WALL="$color240$WALL$reset"
		}
		#########################################################################
		# This is a way of looking at the top and bottom of a file.
		#########################################################################
		headAndTail() {
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ inspect file 10"; return 0; fi
			if [ -s "$1" ]; then
				wall
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
			ARGNUM=1
			for f in $ARGTERMS; do 
				color=${array[i]}
				printf "\e[38;5;${color}m$ARGNUM: $f$reset\n"
				((ARGNUM++))
				((i++))
			done
			echo $WALL
			echo
		}

		colorize() {
			printf "";
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

		#########################################################################
		# For tab-separated files, this will look at the top, bottom, highlight line numbers and color the columns.
		#########################################################################
		allTheThings() {
			inspect $1 $2 | highlight stdin LINENUMBERS | columns stdin
		}

		#########################################################################
		# This is useful for looking for chunks that match a pattern, eg. 	#
		# errors in a log file.	Gives you nicely formatted output.		#
		#									#
		#	$ showMatches file.txt pattern [10]				#
		#									#
		#	The pattern can use basic regex.				#
		#########################################################################
		showMatches() {
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ showMatches file.txt pattern 10"; return 0; fi
			if [ -s "$1" ]; then
				if [ "$2" == "" ]; then echo "You didn't provide a valid pattern"; return 0; fi
				DIVISIONBORDER="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
				if [ -z "$3" ]; then NUMBER=5; else NUMBER=$3; fi
				cat $1 | nl | sed "s/\(.*$2.*\)/$DIVISIONBORDER\n\1/g" | grep --no-group-separator -A$NUMBER "$DIVISIONBORDER" | GREP_COLOR='00;48;5;201' grep --color=always "$2\|" 
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
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
		needHelp() {
			if [ "$FILE" == "-h" ] || [ "$FILE" == "--help" ]; then
				FILE="help"
			fi
		}
		
		#########################################################################
		# This collapses a tag storm
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
			#if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ listAllTags meta.txt"; return 0; fi
			#if [ -s "$1" ]; then
				cdwTags=$(grep --no-group-separator -A1000 cdwAllowedTags ~ceisenhart/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",$//g')
				misceTags=$(grep --no-group-separator -A1000 misceAllowedTags ~ceisenhart/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",[[:blank:]]*$//g' )
				allTags=$( printf "$cdwTags\n$misceTags\n" | sort | uniq)
				echo "$allTags" # | sed "s/'//g" | sed "s/^/^[[:blank:]]*/g" | sed "s/$/\\\s/g"
			#else
			#	echo "Please provide a filename that exists and has content."
			#fi
		}
		#########################################################################
		# This collapses a tag storm, then passes it to highlight. Only valid tags are highlighted.
		#########################################################################
		checkTagsValid() {
		#	grabTagStorm

		#	OR GRAB MANIFEST COLUMN
		#
			echo $TAGSTORM
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ listAllTags meta.txt"; return 0; fi
			if [ -s "$1" ]; then
				listAllTags $1 | ~clay/ontogeny/bin/ontogeny_highlight.sh stdin $(listValidTags | sed "s/'//g" | sed "s/^/^[[:blank:]]*/g" | sed "s/$/\\\s/g") | tail -n +5 | sed '$d' | sed '$d'  | sed '$d'
			else
				echo "Please provide a filename that exists and has content."
			fi
		}
		
		#########################################################################
		# This will show the content between two matches. Note that the first match is used.
		#########################################################################
		grabBetween(){
			if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then echo "usage:"; echo "	$ grabBetween file.txt firstPattern secondPattern"; return 0; fi
			if [ -s "$1" ]; then
				# nl --body-numbering=a
				cat $1 | grep --no-group-separator -A500 $2 | grep --no-group-separator -B500 -m1 $3 | GREP_COLOR='00;48;5;25' grep --color=always "$2\|" | GREP_COLOR='00;48;5;107' grep --color=always "$3\|"
			else
				echo "Please provide a filename that exists and has content."
			fi
		}

		alias convertMisceFields=" head -n 1 | tr '[[:upper:]]' '[[:lower:]]' | tr ' ' '_' | tr '-' '_' | sed 's/__/_/g'"
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
		alias inspectHere=inspectSubmission
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
#		alias cdwSubmitted="hgsql cdw -e \"select distinct(TRIM(LEADING 'local://localhost//data/cirm/wrangle/' FROM url)),MAX(id),MAX(FROM_UNIXTIME(startUploadTime)),wrangler from cdwSubmit where url NOT LIKE 'local://localhost//data/cirm/submit/%' group by url order by id\""
#		alias listSubmissions="cdwSubmitted | highlight stdin $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | tr '\n' ' ') |  tail -n +4 | head -n $(cdwSubmitted | wc -l) | columns stdin | tail -n +3 | head -n $(($(cdwSubmitted | wc -l) + 2)); echo $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | sort | uniq | wc -l) data sets and $(cdwSubmitted | tail -n +2 | cut -f 1 -d '/' | wc -l) submissions."
#		alias submitted="hgsql cdw -B -N -e \"SELECT id,TRIM(LEADING 'local://localhost//data/cirm/wrangle/' FROM url),FROM_UNIXTIME(startUploadTime),wrangler FROM cdwSubmit ORDER BY id;\" " #| tail -n +4 | head -n $(( $(submitted | wc -l) - 6 )) "
#		alias submissions="submitted | highlight stdin $(submitted | cut -f 2 | cut -f 1 -d '/' | sort | uniq | tr '\n' ' ') $(submitted | cut -f 4 | sort | uniq | tr '\n' ' ') | tail -n +5 | head -n $(submitted | wc -l)"

		#########################################################################
		# Wrangler-curated stuff						#
		#########################################################################
		alias cdwDataSets="hgsql cdw -e 'select id,name,label,description,metaDivTags,metaLabelTags from cdwDataset\G' | GREP_COLOR='00;38;5;107' grep --color=always \$'^[[:blank:]]*name.*\|' | GREP_COLOR='00;38;5;200' grep --color=always \$'^[[:blank:]]*label.*\|' | GREP_COLOR='00;38;5;117' grep --color=always \$'^[[:blank:]]*description.*\|' | GREP_COLOR='00;38;5;202' grep --color=always \$'^[[:blank:]]*metaDivTags.*\|' | GREP_COLOR='00;38;5;25' grep --color=always \$'^[[:blank:]]*metaLabelTags.*\|' | GREP_COLOR='00;38;5;236' grep --color=always \$'^\**.*\|'"
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


