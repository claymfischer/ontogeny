#!/usr/bin/env bash

#################################################################################
# .bash_profile									#
#################################################################################
# This is only loaded on startup, whereas your .bashrc can be loaded when executing programs.

	#########################################################################
	# Source .bashrc							#
	#########################################################################
	if [ -f ~/.bashrc ]; then
		. ~/.bashrc
	fi

	#########################################################################
	# Change window title to indicate where I am				#
	#########################################################################
	WHICHSERVER=$(uname -n)
	if [ "$WHICHSERVER" == "hgwdev" ]; then
		colorAsciiArt=$(echo -en "\e[38;5;107m")
		echo -e "\033]; 🌀  Welcome to hgwdev \007"
	else
		colorAsciiArt=$(echo -en "\e[38;5;166m")
		echo -e "\033]; ☢  Welcome to cirm \007"
	fi

	#########################################################################
	# ASCII art as visual indication which server I am on			#
	#########################################################################
	reset=$(echo -en "\e[0m")
	clear
	echo "$colorAsciiArt"
	cat << 'EOF'

    `-:-.   ,-;"`-:-.   ,-;"`-:-.   ,-;"`-:-.   ,-;"
       `=`,'=/     `=`,'=/     `=`,'=/     `=`,'=/
         y==/        y==/        y==/        y==/
       ,=,-<=`.    ,=,-<=`.    ,=,-<=`.    ,=,-<=`.
    ,-'-'   `-=_,-'-'   `-=_,-'-'   `-=_,-'-'   `-=_

EOF
	echo "$reset"
