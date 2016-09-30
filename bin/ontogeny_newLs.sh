#!/usr/bin/env bash

reset=$(echo -en "\033[0m")

color25=$(echo -en "\e[38;5;25m") ;
color40=$(echo -en "\e[38;5;40m") ;

printf "\n"
ls | while read file; do if [ -d "$file" ]; then echo "$color25$file$reset/"; fi; done | sed 's/^/   /g'
ls | while read file; do 
	if [ -f "$file" ]; then 
		if [ -x "$file" ]; then
			echo "$color40$file$reset" 
		else
			echo "$file" 
		fi
	fi
	
done | sed 's/^/   /g'
printf "\n"

