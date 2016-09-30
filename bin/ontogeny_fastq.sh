#!/usr/bin/env bash

#################################################################################
# Usage
#################################################################################
# $ fastq file.fastq.gz
# Setting any third argument will color code the quality scores:
#	$ fastq file.fastq.gz x

#################################################################################
# Limitations
#################################################################################
# Just for fastq.gz files

#################################################################################
# Config
#################################################################################

# This is going to run in a subshell, so this should not affect your main shell.
export LANG="en_US.UTF-8"
export TERM=xterm-256color


FILE=$1

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "$ fastq.sh file [set any additional argument to color code quality scores]"
	exit 0
fi

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
color236=$(echo -en "\e[38;5;236m") ;
color240=$(echo -en "\e[38;5;240m") ;

bg25=$(echo -en "\e[48;5;25m") ;
bg106=$(echo -en "\e[48;5;106m") ;
bg114=$(echo -en "\e[48;5;114m") ;
bg117=$(echo -en "\e[48;5;117m") ;
bg196=$(echo -en "\e[48;5;196m") ;
bg200=$(echo -en "\e[48;5;200m") ;
bg202=$(echo -en "\e[48;5;202m") ;
bg240=$(echo -en "\e[48;5;240m") ;

reset=$(echo -en "\033[0m")
FILEEXT=$(echo $FILE | rev | cut -f 1 -d '.' | rev)
LINE=1
scoreToAscii() {
	LC_CTYPE=C printf '%d' "$1" 
}
ord() {
  LC_CTYPE=C printf '%d' "'$1"
}
if [ "$FILEEXT" == "gz" ]; then
	zcat $FILE | while read line; do
		whichline=$(expr $LINE % 4)
		if [ "$whichline" == "1" ]; then printf "$color25$line$reset\n"; fi
		if [ "$whichline" == "2" ]; then 
			printf "$line$reset\n" | 
			LC_CTYPE=C GREP_COLOR='00;48;5;226' grep --color=always $'A\|' | 	# YELLOW
			LC_CTYPE=C GREP_COLOR='00;48;5;210' grep --color=always $'C\|' |	# red
			LC_CTYPE=C GREP_COLOR='00;48;5;81' grep --color=always $'G\|' |		# blue
			LC_CTYPE=C GREP_COLOR='00;48;5;113' grep --color=always $'T\|'		# green
		fi
		if [ "$whichline" == "3" ]; then printf "$color240$line$reset\n"; fi
		if [ "$whichline" == "0" ]; then
			if [ -n "$2" ]; then
				grep -o . <<< "$line" | while read letter; do 
					VALUE=$(ord $letter)
					VALUE=$((VALUE-33))  
					VALUE=$((VALUE / 3))
					VALUE=$((VALUE+232))
					printf "\e[48;5;${VALUE}m"
					printf "$letter"
				done
				printf "$reset\n"
			else
				printf "$line\n"
			fi
		fi
		((LINE++))
	done
fi | less -R
