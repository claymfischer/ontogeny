#!/usr/bin/env bash


#################################################################################
# Purpose									#
#										#
#	it's easier to see what's going on if directories are listed first, 	#
#	then list the files after.						#
#										#
#################################################################################


# Usage
#
#	$ nls


#################################################################################
# Config/settings								#
#################################################################################
reset=$(echo -en "\033[0m")
color25=$(echo -en "\e[38;5;25m") ;
color69=$(echo -en "\e[38;5;69m") ;
color70=$(echo -en "\e[38;5;70m") ;
color114=$(echo -en "\e[38;5;114m") ;
color166=$(echo -en "\e[38;5;166m") ;
color240=$(echo -en "\e[38;5;240m") ;
BASHFILES=$(echo -en "\e[48;5;240m") ;


#################################################################################
# Format the screen so it's easier to read.					#
#################################################################################
clear
printf "\n\n"


#################################################################################
# A list of directories is easy!						#
#################################################################################
ls | while read line; do if [ -d $line ]; then echo "  $color25$line$reset/"; fi; done


#################################################################################
# Let's be a little more specific with files by differentially coloring them.	#
#################################################################################
ls | while read line; do if [ -f $line ]; then 

	#########################################################################
	# Let's figure out if UNIX thinks this is an ASCII file			#
	#########################################################################
	FILETYPE=$(file $line | cut -f 2 -d' ')

	#########################################################################
	# However, all text files we can know their length!			#
	#########################################################################
	ISTEXTPLAIN=$(file --mime-type $line | cut -f 2 -d ' ')
	if [ "$ISTEXTPLAIN" == "text/plain" ]; then
		TEXTFILELENGTH=$(wc -l $line | cut -f 1 -d " ")
		LENGTH="$TEXTFILELENGTH lines$reset"
	else
		LENGTH="$reset"
	fi

	#########################################################################
	# May as well grab the file extension					#
	#########################################################################
	FILEEXTENSION=$(echo $line | rev | cut -f 1 -d '.' | rev)

	#########################################################################
	# It's easy to figure out if a file is executable! We can set this to a	#
	# variable and notify people about executables.				#
	#########################################################################
	if [[ -x "$line" ]]; then
		ISEXECUTABLE="${color70}executable"
	else
		ISEXECUTABLE=""
	fi

	#########################################################################
	# Begin template for output. Let's have an indent.			#
	#########################################################################
	printf "  "

	#########################################################################
	# Using the above variables, we can color things differentially.	#
	#########################################################################
	if [ "$FILETYPE" == "ASCII" ] || [ "$FILEEXTENSION" == "txt" ]; then

		#################################################################
		# What color would we like for a simple ASCII/text file?	#
		#################################################################
		TEMPLATE=$color240;

	elif [ "$FILEEXTENSION" == "sh" ]; then

		#################################################################
		# What color would we like for a shell script?			#
		#################################################################
		TEMPLATE=$BASHFILES; 

	else

		#################################################################
		# What color would we like for all other files?			#
		#################################################################
		TEMPLATE="";

	fi
	
	#########################################################################
	# printf allows us to define column width for printing, helping us to	#
	# align our output. This makes it easier to read!			#
	#########################################################################
	printf "%-0s %-35s %-1s %-0s %-20s %-1s %25s\n" "$TEMPLATE" "$line" "$reset" "$TEMPLATE" "$LENGTH" "$reset" "$ISEXECUTABLE"
	printf "$reset"
fi; done

printf "\n\n"


