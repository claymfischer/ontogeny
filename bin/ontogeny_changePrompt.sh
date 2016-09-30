#!/usr/bin/env bash

#################################################################################
#  Purpose:
#################################################################################
#	We want to change our PS1 prompt to a random animal. 
#	Non-permanence: when a new terminal is opened, it always goes back to our default.

#################################################################################
# Usage										#
#################################################################################
#
# Set an alias 'critters' that points to this file.
#	critters on
#	critters off
#	critters new
#	critters reset
#	critters (help)
#
#
# LIMITATIONS
#
#	If you use this in two terminals, one might delete the file saving your original PS1 variable, so you can't reset
#
# 	This uses unicode, requiring us to set LANG to a value which may cause issues with sort.


#################################################################################
# User config									#
#################################################################################
TEMPFILE=$HOME/.PS1.reset.txt # this file remains until you run this script with the 'reset' argument
PROMPTSCRIPT=~/ontogeny/bin/ontogeny_changePrompt.sh

# changes the way sort behaves
#make sure they are supporting unicode characters - make sure to change back to LANG=C LC_ALL=C LC_COLLATE=C as this can affect ability to srt.
export LANG="en_US.UTF-8"

reset=$(echo -en "\033[0m")

color25=$(echo -en "\e[38;5;25m") ;
color69=$(echo -en "\e[38;5;69m") ;
color70=$(echo -en "\e[38;5;70m") ;
color114=$(echo -en "\e[38;5;114m") ;
color166=$(echo -en "\e[38;5;166m") ;
color240=$(echo -en "\e[38;5;240m") ;

bg196=$(echo -en "\e[48;5;196m") ;


#################################################################################
# select a random unicode symbol from the array below.				#
#################################################################################
# Here are some examples: 🍉 🍀 ☘ 🐸 🐶 🐹 🐮 🐙 🐳 🐟 ☢ ✳️ ⭕️ Ⓜ️ ☑️ 🔘 ⚪️ ⚫️ 🔴 🔵
        arr[0]="🐶"
        arr[1]="🐸"
        arr[2]="🐟"
	arr[3]="🐙"
	arr[4]="🐾"
	arr[5]="🐕"
	
	# the modulus here needs to be the number in the array above minus one.
        rand=$[ $RANDOM % 6 ] # this number needs to be equal to your array size.
        i=${arr[$rand]}

#################################################################################
# Test if it's their first time running this script (in this session) and save  #
# their current PS1 so we can reset it.						#
#################################################################################
if [ -z "$FIRSTEXECUTION" ] || [ "$FIRSTEXECUTION" -lt "1" ]; then
	# This is their first time running it, let's save their current PS1 into a file.
	echo "export PS1='$PS1'" > $TEMPFILE
fi

#################################################################################
# Handle arguments								#
#################################################################################
if [ "$1" == "on" ]; then
	PROMPT_COMMAND="source $PROMPTSCRIPT new"
elif [ "$1" == "new" ]; then


	#########################################################################
	# Let's set the actual PS1 variable!					#
	#########################################################################
	export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;25m\]\u\[\e[38;5;240m\]@\[\e[38;5;107m\]\h \[\e[m\]\[\e[38;5;240m\]\W/\[\e[0m\]\[\e[m\] \[\e[m\]\[\e[38;5;25m\]$i \[\e[0m\] '

elif [ "$1" == "reset" ]; then
	#########################################################################
	#			#
	#########################################################################
	source $TEMPFILE
	PROMPT_COMMAND=""
	rm $TEMPFILE
elif [ "$1" == "off" ]; then
	#########################################################################
	#			#
	#########################################################################
	PROMPT_COMMAND=""
else 
	#########################################################################
	# they have no argument... we can show a help message			#
	#########################################################################
	clear
	printf '\n\n'
	echo "	$bg196 HELP $reset"
	echo ""
	echo "	Purpose: to change your command prompt icon"
	echo ""
	echo "	Usage: "
	echo "		${color25}promptScript ${color166}on $reset"
	echo ""
	echo "	Running it without an agument (on, off, reset) will display help."
	echo "	Running it with 'new' will change your prompt randomly once for this session."
	echo "	Running it with 'on' will change each prompt randomly for this session."
	echo "	Running it with 'off' will make the next prompt stay. "
	echo "	Running it with 'reset' will bring you back to your old prompt when you started."
	echo ""
	echo "	None of these changes are permanent, and you'll be back to normal with every new session!"
	printf '\n\n\tCommand prompt icon preview: '
	for i in ${arr[@]}; do printf " $i "; done
	printf '\n\n'
	
fi



#################################################################################
# By setting a variable here, we can determine if it's their first time running #
# the script. Increment it every time.						#
#################################################################################
FIRSTEXECUTION=0
((FIRSTEXECUTION++))


