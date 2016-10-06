#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_tagSummary.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# 

#################################################################################
# Usage
#################################################################################
#

#################################################################################
# Limitations
#################################################################################

################################################################################
# 
################################################################################

clear
reset=$(echo -en "\033[0m")
color25=$(echo -en "\e[38;5;25m") ;
color114=$(echo -en "\e[38;5;114m") ;
color202=$(echo -en "\e[38;5;202m") ;
color240=$(echo -en "\e[38;5;240m") ;

FILE=$1
TERM=$2
SHOW=$3
EXAMPLES=$4

if [ -z $1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	printf "\n\n"
        echo "$color240 ╔════════════════════════════════════════════════════════════════════════════════╗$reset"
	echo "$color114   tagSummary						$color240  github.com/claymfischer"
	echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
	echo "   ABOUT"
	echo "   	"
	echo "   	A quick method of learning all about a tag in a tag storm. Provides basic"
	echo "   	metrics, examples of all unique tags including their stanza, and generates"
	echo "   	a list of all values the tag provides to aid in wrangling."
	echo "   	"
	echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
	echo "   USAGE"
	echo ""
	echo "   	$ ${color25}tagSummary$color202 meta.txt ${color114}age $reset"
	echo "   	"
	echo "   		There are ${color25}28$reset total instances of ${color114}age$reset in ${color202}meta.txt$reset"
	echo "   		Of these, ${color25}17$reset instances are unique, and if you ignore the leading white space ${color25}9$reset are unique."
	echo "   	"
	echo "   	$ ${color25}tagSummary$color202 meta.txt ${color114}age$color240 x$reset"
	echo "   	"
	echo " 		In addition to the above, it will show you all unique instances including"
	echo "		stanza. ${color240}x$reset can be anything, it just needs to exist."
	echo "   	"
	echo "   	$ ${color25}tagSummary$color202 meta.txt ${color114}age$color240 x x$reset"
	echo "   	"
	echo "		In addition to the above, it will give you a list of the values separated "
	echo "		by a bar (eg. 12  | 13 | 33 | 35)."
	echo ""
	echo "$color240   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
	echo "   PROTIP"
	echo ""
	echo "	The asterisk in the summary indicates that it's searching all tags that match."
	echo "	To disable this and only look for a specific tag, enclose it in quotes with a space at the end:"
	echo ""
	echo "$color240		$ ${color25}tagSummary$color202 meta.txt ${color114} 'tag '$reset"
	echo ""
        echo "$color240 ╚════════════════════════════════════════════════════════════════════════════════╝$reset"
	printf "\n\n"
	exit 0
fi


#################################################################################
# how should we handle a file not found?					#
#################################################################################

if [ -s "$FILE" ]; then
	printf "";
else
	printf "\n\n"
        echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
	echo "   The file ${color202}$FILE$reset doesn't appear to exist."
	echo ""

                caseSensitive=$(shopt nocaseglob)
                if [ "$caseSensitive" = "nocaseglob     	off" ]; then
                        shopt -s nocaseglob; { sleep 3 && shopt -u nocaseglob & };
                fi

                similarfiles=$( ls -d ${FILE:0:1}* | sort | wc -l )
                echo "        Perhaps you intended to look at one of the following $bg25$similarfiles$reset files (setting case insensitive for an instant):" 
                echo ""
                echo "                $ ls -d ${FILE:0:1}*$color25"
                # some directories have a ton of files that may match, like srr*, so let's split this up to avoid a flood.
                if [ "$similarfiles" -lt 20 ]; then
                        ls -d ${FILE:0:1}* | sort | sed "s/^/                /"
                else
                        ls -d ${FILE:0:1}* | sort | sed "s/^/                /" | head -15
                        echo ""
                        echo "                $white[ ... ]$color25"
                        echo ""
                        ls -d ${FILE:0:1}* | sort | sed "s/^/                /" | tail -15
                fi
                echo ""
                echo "$reset"

        echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
	printf "\n\n"
	exit 0
fi

################################################################################
# how should we handle a tag not found in a file?
################################################################################
if grep -q -i "^\([[:blank:]]*\)$TERM" $FILE; then
	printf ""
else
	printf "\n\n"
        echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
	echo "   The tag ${color114}$TERM$reset was not found in ${color202}$FILE$reset"
        echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
	printf "\n\n"
	exit 0
fi

################################################################################
# how should we handle a tag found in a file? 
################################################################################
# WILDCARD='' to enable lab_surname* or WILDCARD=' ' to disable. This puts a space after $TERM below
WILDCARD=''

INSTANCES=$(cat $FILE | grep -i "^\([[:blank:]]*\)$TERM$WILDCARD" | wc -l)
UNIQUEINSTANCES=$(cat $FILE | grep -i "^\([[:blank:]]*\)$TERM$WILDCARD" | awk NF | sort | uniq | wc -l) # We could collapse the white space for a more accurate count.
UNIQUEINSTANCESCOLLAPSED=$(cat $FILE | grep -i "^\([[:blank:]]*\)$TERM$WILDCARD" | sed 's/\t//g' | awk NF | sort | uniq | wc -l) # We could collapse the white space for a more accurate count.

if [ -n "$SHOW" ]; then
        echo ""
        echo " ╔════════════════════════════════════════════════════════════════════════════════╗"
        echo ""
	# If we wanted sort to ignore white spaces... LC_ALL=C sort
	# however I like seeing the white spaces counted differently, as the stanza blocks convey information
	echo "   $color25$UNIQUEINSTANCES$reset unique instances of this tag's value are sorted, not in order, with stanza"
	echo "   preserved and occurences tallied."
        echo "$color240"
	# Would be nice to show the sort where the leading white space is sorted too. supposedly this ought to work, but doesn't: sort -b -t$'\t'
	echo " 	0	1	2	3	4"
	echo "   "
        cat $FILE | grep -i "^\([[:blank:]]*\)$TERM$WILDCARD" | sort | uniq | while IFS='' read line; do printInstances=$(cat $FILE | grep "^$line$" | wc -l;); printf "   [$printInstances]\t$line\n"; done;
        printf "$reset\n"
        if [ -n "$EXAMPLES" ]; then
                echo "   Sorted list of all $color25$UNIQUEINSTANCESCOLLAPSED$reset unique values for this tag$color240"
                echo ""
                cat $FILE | grep -i "^\([[:blank:]]*\)$TERM$WILDCARD" | sed 's/\t//g' | sort | uniq | awk NF | cut -d " " -f 2- | tr '\n' '|' | sed 's/|$//g' | sed 's/|/ | /g' | sed "s/^/   /"
                echo "$reset"
                echo ""
        fi
        echo " ╚════════════════════════════════════════════════════════════════════════════════╝"
else
        printf ""
fi

# determine if we have a space in our term to show an asterisk or not
if [[ "$TERM" =~ \ |\' ]]; then
	asterisk=""
else
	asterisk="* "
fi

printf "\n  There are $color25$INSTANCES$reset total instances of $color114$TERM$asterisk${reset}in $color202$FILE$reset\n";
printf "  Of these, $color25$UNIQUEINSTANCES$reset instances are unique, and if you ignore the leading white space $color25$UNIQUEINSTANCESCOLLAPSED$reset are unique.\n\n"

