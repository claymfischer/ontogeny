#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_about.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# Generate metrics on, and inspect, text files and directories.

#################################################################################
# Usage
#################################################################################
#

#################################################################################
# Limitations
#################################################################################

#########################################################################
# To do 								#
#########################################################################
	# when looking at directories, fix nl bug.
	#
	# Not a big deal, but should sed -i 's/        /\t/g' generateFileMetrics.sh just to be consistent... what about four spaces?
	#
	# The file path in the display is a little funny sometimes. 
	#	I don't want to use just or $PWD because sometimes it's run in an absolute path instead of relative, eg. we are in a directory and run $ about ~/file.txt
	#	Doesn't affect metrics, only user readability, so I never spent time on it. 
	# 
	# The directory metrics can take a while on a large directory. Implement a waiting message every second? a simple recursive function that calls itself...
	# 	SECONDS=0; while $SECONDS = multiple of 1 do echo "Patience..."; sleep 1, check again" else done
	#	Maybe easier to just see if the process is running.
	#	Either way, not a priority.
	#
	# If using -b should it generate a $FILE.snap.date.time?
	#	output > $FILE.$(date +%F).$(date +"%H_%M_%S")
	#
	# Organize variables and name them better. For instance, when validating:
	#	$ file file.txt
	#	file.txt: UTF-8 Unicode English text
	#	FILETYPE1=
	#	FILETYPE2=
	#	This way they are easier to use down below.
	# $OUTPUTSTYLE is another example of an oddly-named variable...
	#
	# Some things are in odd orders, because they rely on variables being set. If I put them in functions instead, they can be grouped more logically and invoked as needed.
	# 
	# When styling output in columns, the nl output can mess things up if we set a delimiter. This will eventually be fixed if I build a preview output systematically and pipe to | nl -b a
	#	cat 7NOV2014.CIRM.chips.csv | column -s , -t | nl -b a	# Works right
	#	nl 7NOV2014.CIRM.chips.csv | column -s , -t 		# Doesn't work right, currently what script does
	#  
	# This first draft could use some MAJOR code cleanup, but it works as needed... my time is better spent elsewhere, for now. 
	# 	I've just been adding to it as I need, and it's become a hodgepodge patchwork script, yet functions just fine

#########################################################################
# Config                                                                #
#########################################################################

        #########################################################################
        # Color variables							#
        #########################################################################
	reset=`tput sgr0`
	off='\033[0m'       # Text Reset
	white=`tput setaf 7`
	
	color105=$(echo -en "\e[38;5;105m")
	color113=$(echo -en "\e[38;5;113m")
	color15=$(echo -en "\e[38;5;15m")
	color16=$(echo -en "\e[38;5;16m")
	color196=$(echo -en "\e[38;5;196m")
	color199=$(echo -en "\e[38;5;199m")
	color202=$(echo -en "\e[38;5;202m")
	color240=$(echo -en "\e[38;5;240m")
	color25=$(echo -en "\e[38;5;25m")
	color255=$(echo -en "\e[38;5;255m")
	bg25=$(echo -en "\e[48;5;25m")
	bg99=$(echo -en "\e[48;5;99m")
	bg196=$(echo -en "\e[48;5;196m")

	#########################################################################
	# Set up gradients here to re-use.					#
	#########################################################################

		#########################################################################
		# Blue									#
		#########################################################################
		GRADIENT=$(for i in {16..21} ; do echo -en "\e[48;5;${i}m        " ; done ; )
		GRADIENTEND=$(for i in {21..16} ; do echo -en "\e[48;5;${i}m        \e[0m" ; done ;)
		#########################################################################
		# Gray									#
		#########################################################################
		GRADIENT2=$(for i in {232..249} ; do echo -en "\e[48;5;${i}m  " ; done ; )
		GRADIENT2END=$(for i in {249..232} ; do echo -en "\e[48;5;${i}m  \e[0m" ; done ;)
		#########################################################################
		# Red to yellow								#
		#########################################################################
		WARNINGGRADIENT=$(
	  		range2="220 214 208 202 196 196"
	  		range1="196 196 202 208 214 220"
        		printf "\n\n\t"; 
			for range in $range1; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m      "; i=$(( $i + 1 )); done; done;
			printf "          "
			for range in $range2; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m      "; i=$(( $i + 1 )); done; done; echo $reset;
		)
		#########################################################################
		# File preview gradient is after the case / optarg section		#
		#########################################################################

        #########################################################################
        # Terminal configuration						#
        #########################################################################
	clear					#
	umask 002				#
	#set -beEu -o pipefail			# Quit if something within the script fails
	OPTIND=1				# Reset is necessary if getopts was used previously in the script. It is a good idea to make this local in a function. 
	#########################################################################
	# Arguments from the command line for 'lazy syntax'			#
	#########################################################################
	FILE=$1					# Allows $ about file.txt [all|n] instead of $ about -f file.txt, but doesn't allow use of flags
	ALIASUSED="about"		 	# If we could read their bash command, we could $ cut last from /" | rev | cut -d'/' -f 1 | rev
	#########################################################################
	# Set some variables for Help/usage and other sections			#
	#########################################################################
	COMMANDUSED=$*				# This is for various help dialog.
	PREVIEW=10 				# 10 is a good number that fits on my 13" MacBook screen
	RECOMMENDEDDUMP=$(($PREVIEW*2 +4))	# How small should a file be to not split the preview into head and tail? Default is RECOMMENDEDDUMP=$(($PREVIEW*2 +4))
	SPACE="\t" 				# The main indent
	SPACING=""				# Here just in case
	SPACING2="\t"				# The indent for the preview
	RELATIVEPATH=$PWD			# This may be reset if about is used on an absolute path
	PREVIEWTOOBIG=100			# This says when to prompt for prevwing a whole file to avoid flooding
	#########################################################################
	# Users can customize the following section				#
	# 									#
	# 	Feel free to edit this section of variables.			#
	# 	User-configured variables here will override the above.		#
	# 									#
	#########################################################################
	DUMPALL=$RECOMMENDEDDUMP 		# I recommend ($PREVIEW*2)+4a, default here would be 24 if preview is 10
	COLUMNDELIMITER=","			# This is set by the optarg now. Deprecated.
	LINENUMBERS="yes" 			# yes || no


#########################################################################
# Set up some functions to call later on in the script....		#
# UPDATE: these got pretty big over time, and most are only called once #
# so maybe just put where they belong?					#
#########################################################################


	#########################################################################
	# 									#
	# 			HELP/USAGE					#
	# 									#
	#########################################################################
	showHelp() {
		cat << EOF


        ==================================================================================

	$white$bg196 HELP $reset             $color240 Script location: $0 $reset

        ----------------------------------------------------------------------------------
	ABOUT

		Describes txt files in human-readable form. Can also use on directories.
		
        ----------------------------------------------------------------------------------
        LAZY USAGE
	
		$ $ALIASUSED$color25 file.txt	$reset	Describes and previews a text file
		$ $ALIASUSED$color25 file.txt $reset${bg25}15$reset		... preview first and last 15 lines
		$ $ALIASUSED$color25 file.txt $reset${bg25}all$reset		... preview entire file
		$ $ALIASUSED $color25.$reset			... look at current directory

        ----------------------------------------------------------------------------------
	QUICKSTART 

		$ $ALIASUSED $color25-f$reset file.txt $color25-a -b -r -w$reset > file.snap

        ----------------------------------------------------------------------------------
	USAGE

		$ $ALIASUSED [$color25-f$reset file.txt] [$color25-hasrb$reset] [$color25-p$reset ${bg25}15$reset] [$color25-d$reset ${bg25}","$reset] [$color25-z$reset]
	
        ----------------------------------------------------------------------------------
	FLAGS
	 
		$ALIASUSED $color25-h$reset			Help/usage
		$ALIASUSED $color25-f$reset file.txt $color25-a$reset 		Preview all lineet
		$ALIASUSED $color25-f$reset file.txt $color25-p $white${bg25}20$reset		Set number of lines to preview
		$ALIASUSED $color25-f$reset file.txt $color25-d $white${bg25}"|"$reset	Define a delimiter
		$ALIASUSED $color25-f$reset file.txt $color25-s$reset		Style preview in columns (uses delimiter if set, recommend adding -b)
		$ALIASUSED $color25-f$reset file.txt $color25-b$reset		Backup style (non-numbered lines in preview)
		$ALIASUSED $color25-f$reset file.txt $color25-w$reset		Wrap preview output
		$ALIASUSED $color25-f$reset file.fastq $color25-r$reset		Force to run (non-text files, and output large files without prompting)
		$ALIASUSED $color25-f$reset file.sh $color25-r -z$reset		Syntax highlighting of file using pygmentize (use -r, and set -z as last flag)

        ==================================================================================


EOF
	}

	#########################################################################
	# 									#
	# 			SHOW COMMAND					#
	# 									#
	#########################################################################
	showCommand() {
	cat << EOF
	Your input:	$ $bg25$white$ALIASUSED $COMMANDUSED$reset

        ==================================================================================


EOF
	}


	#########################################################################
	# 									#
	# 			SHOW INVALID FILE TYPE				#
	# 									#
	#########################################################################
	showError() {
		cat << EOF

	$WARNINGGRADIENT

        This only generates metrics on text or unicode files.

	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset

	You are trying to use this on a$color25 non-supported file type$reset.

		$ file $FILE
		$color196$typeOfFile$reset
	
	To force this to run on a non-supported file without prompt, use the $color25-r$reset flag:

		$ $ALIASUSED $color25-f$reset $FILE $white$bg196-r$reset

	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset


EOF
	}

	#########################################################################
	# 									#
	# 			SHOW FORMATTING BAR				#
	# 									#
	#########################################################################
	showTemplate() {
		cat << EOF

	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset

EOF
	}


	#########################################################################
	# 									#
	# 		SHOW USER INPUT AND MEMORY JOGGER			#
	# 									#
	#########################################################################
	templateFoot() {
		cat << EOF
        $GRADIENT2          $GRADIENT2END

	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset
	Your input: 	$ $bg25$color255 $ALIASUSED $COMMANDUSED $reset
	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset
	Quick usage guide:
 	$ $ALIASUSED $color25-f$reset file.txt $color25-a$reset 		(preview all)	$ $ALIASUSED $color25-f$reset file.txt $color25-s$reset 	(style in columns)
	$ $ALIASUSED $color25-f$reset file.txt $color25-p$reset ${bg25}15$reset	(set preview)	$ $ALIASUSED $color25-f$reset file.txt $color25-r$reset 	(force run)
	$ $ALIASUSED $color25-f$reset file.txt $color25-d$reset ${bg25}','$reset	(set delimiter) $ $ALIASUSED $color25-f$reset file.txt $color25-b$reset 	(backup style)
	$ $ALIASUSED $color25-f$reset file.txt $color25-w$reset		(wrap output)	$ $ALIASUSED $color25-f$reset file.txt $color25-z$reset	(syntax highlighting)
	$color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset


EOF
	}


	#########################################################################
	# 									#
	# 	If file doesn't exist, make suggestion and exit			#
	# 									#
	#########################################################################
	templateNotFound() {
		echo "$WARNINGGRADIENT"
		printf "\n\n"
		echo "        Your input: 	$ $bg25$color15$ALIASUSED $COMMANDUSED$reset"
		echo ""
		echo "        The file $color196$FILE$reset does not exist"
		echo ""
		similarFiles=$( ls -d ${FILE:0:1}* | sort | wc -l ) 
		echo "        Perhaps you intended to look at one of the following $bg25$similarFiles$reset files (setting case insensitive for an instant):" 
		echo ""
		echo "                $ ls -d ${FILE:0:1}*$color25"
		# Some directories have a ton of files that may match, like SRR*, so let's split this up to avoid a flood.
		if [ "$similarFiles" -lt 20 ]; then
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
		showTemplate
		exit 1
	}

#########################################################################
# Input validation for lazy syntax to allow:				#
#									#
#	Lazy usage:			Verbose flag equivalent:	#
#	----------------------------+--------------------------		#
# 	$ about file.txt 25	    |	about -f file.txt -p 25		#
# 	$ about file.txt all	    |	about -f file.txt -a		#
#	----------------------------+--------------------------		#
#									#
# 	This lazy usage does not allow any flags, though		#
#									#
#########################################################################

	#################################################################
	# Validate they put in a number for second argument 		#
	#################################################################
	# DISPLAY=$2
	# if [ "$2" -eq "$2" ] 2>/dev/null; then
	#	DISPLAY=$2
	#else
	#	DISPLAY=""
	#fi
	re='^[0-9]+$'
	if [[ $2 =~ $re ]] ; then
		DISPLAY=$2
	fi
	if [ "$2" = "all" ]; then
		DISPLAY="all"
	fi

#########################################################################
# Invoke Help if no arguments or file					#
#########################################################################

	if [ -z $1 ]; then
		showHelp
		exit 0
	fi

#########################################################################
# Set up how we'll preview the file					#
#########################################################################

	#################################################################
	# Set default to number the lines. 			 	#
	#################################################################
	if [ -s $FILE ]; then
		PREVIEWSTYLE=$(nl -b a $FILE)	
	fi

	#################################################################
	# Default title can be overridden depending on flags	 	#
	#################################################################
	OUTPUTSTYLE="       File preview       "


	###############################################################################
	# This is to allow case-insensitive file suggestions if the filename is misspelled
	###############################################################################
	caseSensitive=$(shopt nocaseglob)
	if [ "$caseSensitive" = "nocaseglob     	off" ]; then
		shopt -s nocaseglob; { sleep 3 && shopt -u nocaseglob & };
	fi 


#########################################################################
# Handle command line flags 						#
#									#
#	Many of these just trip a variable that causes an effect	#
# 	downstream at the main output, so no need for verbose comments	#
#									#
#########################################################################

	#################################################################
	# Set flags here, if a flag needs an argument, colon->$OPTARG	#
	#################################################################
	while getopts "hf:ap:bsrfwd:z" opt
		do
		case $opt in
			h) 	showHelp
				if [ -s $FILE ]; then
					showCommand
				fi
				exit 0
				;;
			f)      FILE=$OPTARG
				#################################################################
				# Let's validate the file and make suggestions if not found	#
				#################################################################
				if [ -e $FILE ]; then
					printf ""
				else 
	
					templateNotFound
				fi
        			PREVIEWSTYLE=$(nl -b a $FILE)
				;;
			a) 	DISPLAY="all"
				;;
			p)	PREVIEW=$OPTARG
				DUMPALL=1
				;;
			b) 	PREVIEWSTYLE=$(cat $FILE)
				SPACING=""
				SPACING2=""
				LINES="yes"
			
				;;
			s) 	STYLE=1
				OUTPUTSTYLE=" File preview (column output) "
				;;
			r)	COERCE="yes"
				;;
			d) 	DELIM=$OPTARG
				;;
			w) 	WRAP="yes"
				;;
			z)	OUTPUTSTYLE="  File preview (pygmentized)  "
				if [ "$LINES" = "yes" ]; then
					PREVIEWSTYLE=$(pygmentize $FILE | nl -b a)
				else
					PREVIEWSTYLE=$(pygmentize $FILE)
				fi
				;;
			m)	# Toggle off maximum columns may go slow... on giant files... though I have tested it and not yet seen it, I expect it
				;;
			?)	showHelp >&2
				
				if [ -s $FILE ]; then
					showCommand
				fi
				
				exit 1
				;;
		esac
	done

	if [ -d $FILE ]; then
		# testing style out...
		range1="22 28 34 40 41"
		range2="41 40 34 28 22"
		# Real quick try another out...
		range1="54 55 56 57 63"
		range2="63 57 56 55 54"
		# try to automate the complement:
		# range2=$(echo $range1 | sort | tac | sed 's/\n//g')
		# Set variables and again and it will just overwrite the above
		range1="17-21 27 26"
		range2="26 27 21 20 19 18 17"
		OUTPUTSTYLE="File extensions found here"
		OUTPUTSTYLE="Files in top level summary"
	else
		range1="17-21 27 26"
		range2="26 27 21 20 19 18 17"
	fi 
	# This needs to be set after the case / optarg
 	PREVIEWGRADIENT=$(
		printf "\t"
		#echo -en "\e[48;5;17m  ";
		for range in $range1; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m    "; i=$(( $i + 1 )); done; done;
		printf "$OUTPUTSTYLE" 
		for range in $range2; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m    "; i=$(( $i + 1 )); done; done; echo "$reset";
		printf "\n"
	)

#########################################################################
# Validation tfor command line flags and arguments 			#
#########################################################################

	#################################################################
	# Let's validate teh file and make suggestions if not found	#
	#################################################################
	if [ -e $FILE ]; then
		printf ""
	else 
		templateNotFound
	fi

	#########################################################################
	# Input validation for file path					#
	#########################################################################
	# Is this an absolute path or relative path?
	# Not sure this will matter in the end...
	FIRSTLETTER=${FILE:0:1}
	if [ "$FIRSTLETTER" == "/" ]; then
		# Reset file path, this is a top-level file.
		RELATIVEPATH=""
	fi

	#################################################################
	# If no command line options supplied				#
	#################################################################
	if [ $OPTIND -eq 1 ] && [ -z $1 ]; then
		showHelp  >&2
		exit 1
	fi
	#################################################################
	# Shift off the options and optional --				#
	#################################################################
	shift "$((OPTIND-1))"	

#########################################################################
# Set up some human-readable stuff					#
#########################################################################

        #########################################################################
        # Display human-readable time. Make modular so it will work for both  	#
	# time last modified and time last accessed.				#
        #########################################################################
	# Convert to seconds, then output appropriate time unit
	# unit   	 seconds 
	#-----------------------
	# Year		31536000
	# Month		 2628000
	# Weeks		     n/a	# gonna skip weeks
	# Day		   86400
	# Hour		    3600
	#-----------------------
	
	MODIFIED=$(( ($(date +%s) - $(date -r $FILE +%s) )))
        PERIOD="years"
        DIVIDE=31536000

	# There is probably a very simple way to do this... but this only took a minute, despite being quite a few lines
	if [ $MODIFIED -lt 31536000 ]; then
                PERIOD="months"
                DIVIDE=2628000
		if [ $MODIFIED -lt 2628000 ]; then
			PERIOD="days"
			DIVIDE=86400

			if [ $MODIFIED -lt 86400 ]; then
				PERIOD="hours"
				DIVIDE=3600 

				if [ $MODIFIED -lt 3600 ]; then
					PERIOD="minutes"
					DIVIDE=60
					if [ $MODIFIED -lt 60 ]; then
					    PERIOD="seconds"
					    DIVIDE=1
					fi

				fi
			fi

		fi
	fi

#########################################################################
# Main Output								#
#########################################################################
	if [ -z $FILE ]; then
		showHelp
	else
		if [ -d $FILE ]; then
        		#########################################################################
        		# Generate Directory Metrics						#
        		#########################################################################
        		echo ""
        		echo ""
        		echo "        $color240══════════════════════════════════════════════════════════════════════════════════$reset"
        		echo -e "        $color240$RELATIVEPATH$reset\e[0m/$white$FILE$reset"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "	This is a directory. Metrics for large directories may be slow, please be patient."
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "        Directory size		Apparent size (eg. if transferring over a network)"
			# Show seconds elapsed while running a bash script
			DIRCONTENTSRECURSIVE=$(find $FILE -type f | wc -l)
			DIRCONTENTS=$(ls $FILE | wc -l )
			DIRSIZE=$(du -sh $FILE | cut -f 1)
			DIRSIZEAPPARENT=$(du -sh --apparent-size $FILE | cut -f 1)
			printf $color202
			printf "\t"
			printf "$DIRSIZE"
			printf "\t\t\t"
			printf "$DIRSIZEAPPARENT"
			printf "\e[0m\n"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "        Number of files		Number of files (recursive)"
			printf "\t$color113"
			printf "$DIRCONTENTS"
			printf "\t\t\t"
			printf "$DIRCONTENTSRECURSIVE"
			printf "\e[0m\n"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "        Last modified					This snapshot was generated"
			printf "$color25"

        		#########################################################################
        		# Do some math, and format the number of decimal places. I think 2.	#
        		#########################################################################
			if [ "$PERIOD" = "months" ] || [ "$PERIOD" = "years" ]; then
				printf "        %.1f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
			else
				printf "        %.0f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
			fi
			DATE=$(date +%F)
			TIMESTAMP=$(date +"%H:%M:%S")
			echo "					$DATE ($TIMESTAMP)"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			#################################################################
			# #
			#################################################################
			echo "$PREVIEWGRADIENT"
			echo ""
			echo "$color240	Count	Extension(s)	Encoding	Example file with that extension$reset"
			# Handle users doing 'about .' instead of 'about ./'
			TRAILING=$(echo $FILE | awk '{print substr($0,length,1)}')
			if [ "$TRAILING" != "/" ]; then FILE="$FILE/"; fi
			echo ""
			# the -p flag appends a trailing / to directories, makes it easier to pick out
			FILEEXT=$(         ls -p $FILE | grep "\." | rev | cut -d'.' -f 1 | rev | sort | uniq -c | sed -e 's/^[ \t]*//' | cut -f 2 -d' ' | sed "s/^//" )
			if [ -n "$FILEEXT" ]; then
				COUNTEXT=$(ls -p $FILE | grep "\." | rev | cut -d'.' -f 1 | rev | sort | uniq -c | sed -e 's/^[ \t]*//' | cut -f 1 -d' ' | sed "s/^/$SPACE$SPACING/" )
			fi
			if [ -n "$FILEEXT" ]; then
				EXAMPLEFILE=$(cd $FILE; echo "$FILEEXT" | while read line; do ls -d *$line | head -1; done | sed "s/^/			/" )
			fi
			if [ -z "$FILEEXT" ]; then
				COUNTEXT="	No file extensions found."
			fi
			# file --mime-type $FILE
			# 	or
			# ascii vs. non-ascii

		#	if [ -n "$FILEEXT" ]; then
		#		EXAMPLEFILE=$(
		#		cd $FILE; echo "$FILEEXT" | while read line; do 
		#		if [ grep "/" "$line" ]; then 
		#			printf ""
		#		else
		#			ISASCII=$(LC_CTYPE=C grep -P "[\x80-\xFF]" $line)
		#			if [ -n "$ISASCII" ]; then
		#				printf "Non-ASCII"
		#			else
		#				printf "ASCII"
		#			fi
		#		fi
		#		ls -d *$line | head -1; done | sed "s/^//"; )
		#	fi
			# We could append a period in front of the file extensions if wanted:
			FILEEXT2=$(printf "\n$FILEEXT" | while read line; do sed "s/^/./"; done )
			paste <(echo "$COUNTEXT") <(echo "$FILEEXT2") <(echo "$EXAMPLEFILE") --delimiters '\t\t'

			echo ""
			directories=$(ls -l $FILE | grep -c ^d)
			files=$(ls -p $FILE | grep -v / | wc -l )
			echo "	There are $color25$directories$reset directories and $color25$files$reset files"
			echo ""

			#################################################################
			# #
			#################################################################
			echo ""
			echo "        ${GRADIENT2}        $GRADIENT2END"
			echo ""
			echo "$color240	Count	Day modified	How long ago	Example file modified that day$reset"
			echo ""
			# This is super fast, but the caveat is: the year isn't printed... however, ls -t puts in chronological order, so should be able to discern age that way if years have gone by...
			UNIQUEDATES=$(ls -lpt --full-time $FILE | tail -n +2 | sed 's/ * / /g' | cut -f 6 -d ' ' | uniq -c )
			FILEMODIFIED=$(echo "$UNIQUEDATES" | sed -e 's/^[ \t]*//' | cut -f 2,3 -d' ' | sed "s/^//")
			COUNTMODIFIED=$(echo "$UNIQUEDATES" | sed -e 's/^[ \t]*//' | cut -f 1 -d' ' | sed "s/^/$SPACE$SPACING/")
			# would be awesome to preserve color for directories, or color them gray
			EXAMPLEMODIFIED=$(echo "$FILEMODIFIED" | while read line; do ls -lpt --full-time $FILE | sed 's/ * / /g' | grep "$line" | head -1 | cut -f 9 -d ' ' | sed "s/^//" ; done )
			if [ -z "$UNIQUEDATES" ]; then
				COUNTMODIFIED="	No files found."
			fi
			# would also be awesome to list how many seconds/days/weeks/months ago modified
			EXAMPLESMODIFIED=$(
				echo "$EXAMPLEMODIFIED" | while read line; do \
					line="$FILE$line"
					THISEXAMPLEMODIFIED=$(( ($(date +%s) - $(date -r $line +%s) )))
					if [ $THISEXAMPLEMODIFIED -lt 31536000 ]; then
                				PERIOD="months"
                				DIVIDE=2628000
						if [ $THISEXAMPLEMODIFIED -lt 2628000 ]; then
							PERIOD="days    "
							DIVIDE=86400

							if [ $THISEXAMPLEMODIFIED -lt 86400 ]; then
								PERIOD="hours  "
								DIVIDE=3600 
	
								if [ $THISEXAMPLEMODIFIED -lt 3600 ]; then
									PERIOD="minutes"
									DIVIDE=60
									if [ $THISEXAMPLEMODIFIED -lt 60 ]; then
									    PERIOD="seconds"
									    DIVIDE=1
									fi
	
								fi
							fi

						fi
					fi

					if [ "$PERIOD" = "months" ] || [ "$PERIOD" = "years" ]; then
						printf "%.1f $PERIOD\n" $(echo $THISEXAMPLEMODIFIED/$DIVIDE | bc -l); 
					else
						printf "%.0f $PERIOD\n" $(echo $THISEXAMPLEMODIFIED/$DIVIDE | bc -l); 
					fi
				done
			)



			# size? I think not useful....
			paste <(echo "$COUNTMODIFIED") <(echo "$FILEMODIFIED") <(echo "$EXAMPLESMODIFIED") <(echo "$EXAMPLEMODIFIED") #--delimiters '\t\t'
			#################################################################
			# #
			#################################################################
	#		echo ""
	#		echo "        ${GRADIENT2}        $GRADIENT2END"
	#		echo ""
	#		#################################################################
	#		# #
	#		#################################################################
	#		echo "$color25	Dates modified		Count		Example file/directory from each day$reset"
	#		echo ""
			# Print out a list of all the dates found in this directory (not recursive0
	#		ls -p $FILE | while read line ; do printf "$(date -r $FILE$line +%F)"; if [ -d $line ]; then printf "$color240"; fi; printf "\t\t\t\t$line$reset\n" ; done | sort -r -u -k1,1 | sed "s/^/$SPACE$SPACING/"
			echo ""
			templateFoot
			exit 0
		fi
		ISTEXT=$(file $FILE | cut -f 3 -d " " )
		ISTEXT2=$(file $FILE | cut -f 2 -d " " )
		ISTXT=$(echo $FILE | rev | cut -f 1 -d'.' | rev )
		if 
		[ "$COERCE" = "yes" ] ||
		[ "$ISTXT" = "txt" ] || 
		[ "$ISTEXT2" = "empty" ] ||
		[ "$ISTEXT" = "text," ] || 
		[ "$ISTEXT" = "text" ] || 
		[ "$ISTEXT" = "English" ] ||
		[ "$ISTEXT" = "Unicode" ] ; then
			#################################################################
			# Redo this in a way which allows us to build a file preview in #
			# the following order, saving headache down below	 	#
			#################################################################
			#	cat $FILE			GENERATE_PREVIEW# Output file
			#	column -s $DELIM -t		PREVIEW_STYLE	# -s can style it
			#	nl -b a				PREVIEW_NL	# by default we number it, -b turns this off
			# 	pygmentize -l py		PREVIEW_SYNTAX	# -z will pipe to here
			#	head -n $DISPLAY		PREVIEW_HEAD	# 
			# 	sed "s/^/$SPACE$SPACING/"	PREVIEW_INDENT	# Allows removing indent if -b used
			#################################################################
			# Systematically build the preview based on vars set above	#
			#################################################################
			# BUILD_PREVIEW=$(cat $FILE)
			


			#################################################################
			# METRICS: ROWS							#
			#################################################################
			LINESALL=$(cat $FILE | wc -l;)
			# Exclude lines that only have whitespace: spaces, new lines or tabs
			LINESSET=$(grep -c "[^ \\n\\t]" $FILE;)
			# Same as above, but also exclude lines that start with hashtags
			LINESCONTENT=$(cat $FILE | grep -v "^#" | grep -c "[^ \\n\\t]";)
	
			#################################################################
			# METRICS: Columns			 			#
			#################################################################
			# Tab-separated fields
			COLUMNSTAB=$(awk -F '\t' '{print NF; exit}' $FILE)
			# Let awk guess at number of fields.
			# This was tricky because different files have different fields in different patterns. I didn't want to over-engineer this, I wanted it robust and generalized
			# Because it partses the whole file, this *may* be the bottleneck of the script...
			# However, I haven't noticed a difference when parsing 25,000-line files with this commented out.
			# If speed is an issue:  exclude lines that begine with a comment, and then just print NF:
			# COLUMNSALL=$(grep -v "^#" $FILE | head -n 1 | awk '{print NF}')
			COLUMNSALL=$(awk '{print NF}' $FILE | sort -nu | tail -n 1)
		#	COLUMNSSPACE=$(awk -F' ' $FILE | sort -nu | tail -n 1)
			if [ -z $DELIM ] ; then
				COLUMNSDELIM="[Use -d to set delimiter]"
			else
				COLUMNSCUSTOM=$(awk '{print NF}' FS=$DELIM $FILE | head -n 1)
				COLUMNSDELIM="Columns ($bg99$white$DELIM$reset)"
			fi

        		#########################################################################
        		# Generate File Metrics                                                 #
        		#########################################################################
        		echo ""
        		echo ""
        		echo "        $color240══════════════════════════════════════════════════════════════════════════════════$reset"
        		#echo "        =================================================================================="
        		echo -e "        $color240$RELATIVEPATH$reset\e[0m${color16}/$white$FILE$reset"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "        File size					Encoding"
			printf $color202
			printf "\t"
        		#########################################################################
        		# Do an ls  and grab only the file inspected, get file size in 		#
			# human-readable format. 						#
        		#########################################################################
			FILESIZE=$(ls -alh $FILE | grep " $FILE$"  | awk '{print $5}')
			printf "$FILESIZE\t\t\t\t\t\t$color199"
			ISASCII=$(LC_CTYPE=C grep -P "[\x80-\xFF]" $FILE)
			if [ -n "$ISASCII" ]; then
				printf "Non-ASCII$color240"
				# printf "\n\t\t\t\t\t\t\e[0m\t$ hexdump -c $FILE"
				printf "\n\t\t\t\t\t\t\t$ LC_CTYPE=C grep --color='auto' -P \"[\\\x80-\\\\xFF]\" $FILE"
			else
				printf "ASCII"
			fi
			printf "\e[0m\n"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			echo "        Last modified					This snapshot was generated"
			printf "$color25"

        		#########################################################################
        		# Do some math, and format the number of decimal places. I think 2.	#
        		#########################################################################
			if [ "$PERIOD" = "months" ] || [ "$PERIOD" = "years" ]; then
				printf "        %.1f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
			else
				printf "        %.0f $PERIOD ago " $(echo $MODIFIED/$DIVIDE | bc -l); 
			fi
			DATE=$(date +%F)
			TIMESTAMP=$(date +"%H:%M:%S")
			echo "					$DATE ($TIMESTAMP)"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"

			# Let's format as columns instead?
			printf "\tLines\t\t\tNon-empty lines\t\tContent-only (disregard hashtags)"
			printf "\n\t$color113$LINESALL \t\t\t$LINESSET \t\t\t$LINESCONTENT\n$reset"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
			printf "\tColumns (tab)\t\tMax columns in a row\t$COLUMNSDELIM"
			printf "\n\t$color105$COLUMNSTAB\t\t\t$COLUMNSALL\t\t\t$COLUMNSCUSTOM\n$reset"
			echo "        $color240━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$reset"
        		echo ""
			#########################################################################
        		# For the file preview, check if they tried to override the default 	#
        		#########################################################################
			echo "$PREVIEWGRADIENT"

			#########################################################################
        		# -w								 	#
        		#########################################################################
			# Disable screen wrapping for eg. 10 seconds so output is a little easier to read
			# On HUGE files (>15,000 lines), this isn't actually long enough and the tail will start wrapping
			if [ -z $WRAP ]; then
				tput rmam; { sleep 3 && tput smam & };
			fi 
			# Use default number of lines in preview
			if [ -z $DISPLAY ]; then
				DISPLAY=$PREVIEW
			fi
			#########################################################################
        		# -a								 	#
        		#########################################################################
			# Did they request all? $ about file.txt all
			if [ "$DISPLAY" = "all" ] || [ "$LINESALL" -lt "$DUMPALL" ] ; then
			
				#########################################################################
				# -r 									#
				#########################################################################
				if [ "$LINESALL" -gt "$PREVIEWTOOBIG" ] && [ "$COERCE" != "yes" ]; then
					echo ""
					echo "        Please confirm you wish to see enire contents of this file before proceeding."
					echo ""
					echo ""
					echo "  ============================================================================================"
					echo "  $bg196$white WARNING: You've requested to preview all $LINESALL lines, this may flood your terminal screen.$reset"
					echo "  ============================================================================================"
					echo ""
					echo ""
					#########################################################################
					# Set up an informative prompt for them					#
					#########################################################################
					select yn in "Continue, preview all $bg196$white$LINESALL$reset lines" "No, do not flood my terminal"; do
						case $yn in
							"Continue, preview all $bg196$white$LINESALL$reset lines" )
								echo ""
								showTemplate
								echo ""
								# All 
								if [ -z $STYLE ]; then
        						                 echo "$PREVIEWSTYLE" | sed "s/^/$SPACE$SPACING/"
       							         else
									# sed -e 's/\t/_|/g' table.txt |  column -t -s '_' | awk '1;!(NR%1){print "-----------------------------------------------------------------------";}'
									if [ -n "$DELIM" ]; then 
                       							 	echo "$PREVIEWSTYLE" | column -s $DELIM -t  |  sed "s/^/$SPACE$SPACING/"
									else
										echo "$PREVIEWSTYLE" | column -t  |  sed "s/^/$SPACE$SPACING/"
									fi
               							fi
								templateFoot
								exit 
								;;
							"No, do not flood my terminal" ) 	clear
								exit
								;;
						esac
					done
				else
				#########################################################################
				# -s		 							#
				#########################################################################
				if [ -z $STYLE ]; then
        		                echo "$PREVIEWSTYLE"  | sed "s/^/$SPACE$SPACING/"
       			         else
					if [ -n "$DELIM" ]; then
                       				 echo "$PREVIEWSTYLE"  | column -s $DELIM -t | sed "s/^/$SPACE$SPACING/"
					else
                       				 echo "$PREVIEWSTYLE"  | column -t | sed "s/^/$SPACE$SPACING/"
					fi
               			fi

				fi

			else 
				#########################################################################
				# Multiple lines 							#
				#########################################################################
				#########################################################################
				# Head									#
				#########################################################################
				if [ -z $STYLE ]; then
					echo "$PREVIEWSTYLE"  | head -n $DISPLAY | sed "s/^/$SPACE$SPACING/" 
				else
					if [ -n "$DELIM" ]; then
						echo "$PREVIEWSTYLE"  | column -s $DELIM -t  | head -n $DISPLAY | sed "s/^/$SPACE$SPACING/"
					else
						echo "$PREVIEWSTYLE"  | column -t  | head -n $DISPLAY | sed "s/^/$SPACE$SPACING/"
					fi 
				fi
				#########################################################################
				# Middle								#
				#########################################################################
				echo "        $GRADIENT2          $GRADIENT2END"
		#		echo "$SPACING2$color25[...]$reset"
				#########################################################################
				# Tail									#
				#########################################################################
				if [ -z $STYLE ]; then
					echo "$PREVIEWSTYLE"  | tail -n $DISPLAY | sed "s/^/$SPACE$SPACING/"
				else
					if [ -n "$DELIM" ]; then
						echo "$PREVIEWSTYLE"  | column -s $DELIM -t | tail -n $DISPLAY | sed "s/^/$SPACE$SPACING/"
					else
						echo "$PREVIEWSTYLE"  | column -t | tail -n $DISPLAY | sed "s/^/$SPACE$SPACING/"
					fi 
				fi
			fi
		 templateFoot

       		#########################################################################
       	 	# END MAIN 								#
       	 	#########################################################################
		else
			typeOfFile=$(file $FILE)
			range1="196 196 202 208 214 220 226 220 214 208 202 196 196"
        		# printf "\t"; for range in $range1; do min=${range%-*}; max=${range#*-}; i=$min; while [ $i -le $max ]; do echo -en "\e[48;5;${i}m     "; i=$(( $i + 1 )); done; done; echo $reset;
        
			showError
			showCommand
			if [ -e $FILE ] && [ "$FORCED" = "" ]; then
				select yn in "Force run" "Okay, won't do that again!"; do
					case $yn in 
						"Force run" )	$0 -f $FILE -r
								exit 0
								;;
						"Okay, won't do that again!" )
								exit 0
								;;
					esac
				done
			fi
		fi
	fi

