#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_transfer.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# This generates an SCP command to quickly transfer files to-and-from your local Mac OS computer and remote server.
#
# Particularly, this is useful when transferring multiple / many files.
#
# It also warns if a file doesn't exist or is empty.

#################################################################################
# Usage
#################################################################################
# $ transfer file.txt file2.txt
# $ transfer *.txt
# $ transfer file.txt *.sh

#################################################################################
# Limitations
#################################################################################
# Doesn't accept stdin. 
#
# This might be useful, for example if you wanted to grab all executable files:
# 	$ ls | while read line; do if [ -x "$line" ] && [ ! -d "$line" ]; then echo "$line"; fi; done | transfer
#
# For now you can instead do this, which works just as well:
#	$ transfer $(ls | while read line; do if [ -x "$line" ] && [ ! -d "$line" ]; then echo "$line"; fi; done)
#
# To do
#	 Could add an argument that would execute the command instead of just giving you it to copy and paste, when uploading.


#################################################################################
# Config - feel free to edit							#
#################################################################################
	LOGINNAME=user
	LOGINSERVER=hgwdev.sdsc.edu
	LOCALDEFAULT=Desktop
	SERVERHOSTNAME=hgwdev
	SERVERHOME=/cluster/home/user

#################################################################################
# Config									#
#################################################################################
	if [ "$(uname)" == "Darwin" ]; then
		ADDAPOSTROPHE=""
	else
	        ADDAPOSTROPHE="'"
	fi
	color22=$(echo -en "\e[38;5;22m") ;
	color25=$(echo -en "\e[38;5;25m") ;
	color69=$(echo -en "\e[38;5;69m") ;
	color70=$(echo -en "\e[38;5;70m") ;
	color81=$(echo -en "\e[38;5;81m") ;
	color106=$(echo -en "\e[38;5;106m") ;
	color114=$(echo -en "\e[38;5;114m") ;
	color117=$(echo -en "\e[38;5;117m") ;
	color166=$(echo -en "\e[38;5;166m") ;
	color196=$(echo -en "\e[38;5;196m") ;
	color200=$(echo -en "\e[38;5;200m") ;
	color202=$(echo -en "\e[38;5;202m") ;
	color203=$(echo -en "\e[38;5;203m") ;
	color207=$(echo -en "\e[38;5;207m") ;
	color215=$(echo -en "\e[38;5;215m") ;
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

	# This is bash's way of determining word boundaries.
	IFS=''

	clear

#################################################################################
# Usage										#
#################################################################################
if [ "$1" == "" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	printf "\n	Purpose\n\n"
	printf "		Run it on the server to generate a command to download files.\n"
	printf "		Run it on your laptop to generate a command to upload files."
	printf "\n	Usage\n\n"
	printf "		$color240$ ${color25}transfer ${color240}file1 file2 ... file5.txt$reset\n\n"
	printf "	This will give you an ouput similar to:\n\n"
	printf "		On $LOGINSERVER:\n"
	printf "		${color81}scp $color25$USER$color240@${color114}$LOGINSERVER$color240:$color207$PWD/$color215{${color203}file1.txt,file2.txt,...file5.txt$color215} ${color215}$LOCALDEFAULT/$reset\n\n"
	printf "		On your laptop:\n"
	printf "		${color81}scp ${color215}$LOCALDEFAULT/$color215{${color203}file1.txt,file2.txt,...file5.txt$color215} $color25$USER$color240@${color114}$LOGINSERVER$color240:$color207/cluster/home/$USER$reset\n\n"
	printf "	$bg81$color232 Protip $reset take advantage of filename expansion by using * to include multiple files, for example:\n\n"
	printf "		$color240$ ${color25}transfer ${color240}commands.sql file.doc $color81*$color240.txt$reset\n\n"
	exit 0
else
#################################################################################
# Generate transfer text							#
#################################################################################
	SERVERSTRING=$(printf "$color25$USER$color240@${color114}$LOGINSERVER$reset:$color207$PWD/$color203")
	MACBOOK=$(printf "${color215}$LOCALDEFAULT/$reset")
	ARGS=$( for f in $@; do echo "${f}"; done | wc -l | sed 's/^ * //g')
	#########################################################################
	# Handle filenames with spaces						#
	#########################################################################
	if [ "$ARGS" == "1" ]; then 
		FILES=$( printf "$color215{$color203$ADDAPOSTROPHE$1$ADDAPOSTROPHE$color215}$reset" )
		if grep -q '[[:blank:]]' $1; then
				FILES=$(printf "$color203$1$reset") 
			fi
	else
		FILES=$(
			printf "$color215{$color203"
			for f in $@; do echo "${f}"; done | while read line; do printf "$ADDAPOSTROPHE$line$ADDAPOSTROPHE," | sed 's/ /\\ /g'; done | tr -d '\n' | sed 's/,$//g' | tr -d '\n'
			printf "$color215}$reset"
		)
		
	fi
	if [ "$SERVERHOSTNAME" == "$HOST" ]; then
		printf "\n	Copy the following command and run it locally to download from ${color114}$LOGINSERVER$reset:\n\n\t\t${color81}scp "
		printf "$SERVERSTRING$FILES $MACBOOK"
	else
		printf "\n	Copy the following command and run it locally to upload to ${color114}$LOGINSERVER$reset:\n\n\t\t${color81}scp "
		printf "$FILES ${color25}$LOGINNAME$color240@${color114}$LOGINSERVER$reset:$color207/cluster/home/${color203}$LOGINNAME"
	fi

	printf "\n"
	printf "\n"
	
	for f in $@; do echo "${f}"; done | while read line; do if [ -s "$line" ]; then printf ""; else printf "\t\t$bg196$white $line $reset doesn't seem to match any real files with contents, it might be misspelled?\n\n"; fi; done
fi

