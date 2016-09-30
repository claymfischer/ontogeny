#!/usr/bin/env bash

# I'd like to figure out why it stops working in directories with a large number of files. 
# noteably, it says scriptbc not found when in a directory with many files.

# formatdir - Wicked Cool Shell Scripts pp. 56

        color25=$(echo -en "\e[38;5;25m") ;
        bg25=$(echo -en "\e[48;5;25m") ;
        color39=$(echo -en "\e[38;5;39m") ;
        bg39=$(echo -en "\e[48;5;39m") ;
        color196=$(echo -en "\e[38;5;196m") ;
        bg196=$(echo -en "\e[48;5;196m") ;
        color240=$(echo -en "\e[38;5;240m") ;
        bg240=$(echo -en "\e[48;5;240m") ;
        reset=`tput sgr0`
        off='\033[0m'

gmk()
{
	# given input in Kb, output in Kb, Mb, or Gb
	if [ $1 -ge 1000000 ] ; then
		echo "$(scriptbc -p 2 $1 / 1000000) Gb"
	elif [ $1 -ge 1000 ] ; then
		echo "$(scriptbc -p 2 $1 / 1000) Mb"
	else
		echo "${1} Kb"
	fi
}


if [ $# -gt 1 ]; then
	echo "Usage: $0 [dirname]" >&2; exit 1
fi
echo ""
for file in *
do
	if [ -d "$file" ] ; then
		size=$(ls "$file" | wc -l | sed 's/[^[:digit:]]//g')
		if [ $size -eq 1 ] ; then
			echo "$color25$file/$reset ($color39$size file$reset)|"
		else
			echo "$color25$file/$reset ($color39$size files$reset)|"
		fi
	else
		size="$(ls -sk "$file" | awk '{print $1}')"
		echo "$color25$reset$file ($color240$(gmk $size)$reset)| "
	fi
done | \
sed 's/ /^^^/g' | \
xargs -n 2	| \
sed 's/\^\^\^/ /g' | \
awk -F\| '{ printf "\t%-70s %22s\n", $1, $2 }' 
echo ""
count=$(ls | wc -l)
echo "	$bg25 $count $reset $bg240 files and/or directories $reset"
echo ""
exit 0

