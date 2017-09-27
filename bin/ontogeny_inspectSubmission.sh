#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer/ontogeny
# ontogeny_inspectSubmission.sh
#################################################################################

#################################################################################
# Purpose
#################################################################################
# Gives a breakdown of a submission directory's history and files currently in it.

#################################################################################
# Usage
#################################################################################
# In any submission directory, run:
# 	$ whatHappened
#
# If you want color-coded output for cdwSubmit (which will compress it, easier to read on small screen)
# then add any additional argument.
#
#	$ whatHappened a
# count metas and manis submitted


	#########################################################################
	# Config								#
	#########################################################################
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
	color255=$(echo -en "\e[38;5;255m")
	#
	reset=$(echo -en "\e[0m")
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
	# Run function so we can start using it
	wall

	transpose() {
		awk '
			BEGIN { FS=OFS="\t" }
			{
    	    	    	    for (rowNr=1;rowNr<=NF;rowNr++) {
        			cell[rowNr,NR] = $rowNr
    	    	    	    }
    	    	    	    maxRows = (NF > maxRows ? NF : maxRows)
    	    	    	    maxCols = NR
			}
			END {
    	    	    	    for (rowNr=1;rowNr<=maxRows;rowNr++) {
        			for (colNr=1;colNr<=maxCols;colNr++) {
            	    	    	    printf "%s%s", cell[rowNr,colNr], (colNr < maxCols ? OFS : ORS)
        			}
    	    	    	    }
			}' $1
	}
	QUARTERLY="	SELECT DATE(CONCAT(YEAR(FROM_UNIXTIME(startUploadTime)),'-', 1 + 3*(QUARTER(FROM_UNIXTIME(startUploadTime))-1),'-01')) AS quarter_beginning,
			max(id) AS submissions
			FROM cdwSubmit
			GROUP BY DATE(CONCAT(YEAR(FROM_UNIXTIME(startUploadTime)),'-', 1 + 3*(QUARTER(FROM_UNIXTIME(startUploadTime))-1),'-01'))
			ORDER BY DATE(CONCAT(YEAR(FROM_UNIXTIME(startUploadTime)),'-', 1 + 3*(QUARTER(FROM_UNIXTIME(startUploadTime))-1),'-01'))"
	MONTHLY="	SELECT DATE(DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%Y-%m-01')) AS month_beginning,
			MAX(id) as submission
			FROM cdwSubmit
			GROUP BY DATE(DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%Y-%m-01'))
			ORDER BY DATE(DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%Y-%m-01'))"

	validateFiles() {
	#	manifestFiles=$(ls -trp *mani* | grep -v "/" | grep -v md5 | grep -v 'lst' | while read line; do if [ -f "$line" ]; then echo "$line"; fi; done)
		manifestFiles=$(find -maxdepth 1 -type f -printf '%Ts\t%p\n' | sort -nr | cut -f 2- | sed 's/^.\///g' | grep mani | grep -v md5 | grep -v 'lst' | grep -v '.swp')
	#	tagStormFiles$(ls -trp *meta* | grep -v "/" | grep -v md5 | grep -v "lst" | grep -v '.tab' |  grep -v metaUp | while read line; do if [ -f "$line" ]; then echo "$line"; fi; done)
		tagStormFiles=$(find -maxdepth 1 -type f -printf '%Ts\t%p\n' | sort -nr | cut -f 2- | sed 's/^.\///g' | grep meta | grep -v md5 | grep -v "lst" | grep -v '.swp' | grep -v '.tab' | grep -v '.tsv' |  grep -v metaUp)
		for f in $tagStormFiles; do
			# basic metrics
			allTags=$(hgsql cdw -e 'describe cdwFileTags;' | cut -f 2 -d '|' | cut -f 1 | sed 's/ //g' | sed 's/\t//g' | tail -n +2 | sort)
			newTags=$(cat $f | sed 's/^[[:blank:]]*//g' | tr '\t' ' ' | cut -d " " -f 1 | sort | uniq | awk NF | while read line; do 
					if echo "$allTags" | grep -iq $line ; then printf ""; else printf "$color240$line$reset, "; fi; 
				done | grep -v "lab_")
			containsNew=$(echo "$newTags" | tr ',' '\n' | wc -l)
			# listvalidtags
			#cdwTags=$(grep --no-group-separator -A1000 cdwAllowedTags ~clay/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",$//g')
			#misceTags=$(grep --no-group-separator -A1000 misceAllowedTags ~clay/kent/src/hg/cirm/cdw/lib/cdwValid.c | grep --no-group-separator -B200 -m1 "}" | tail -n +2 | sed '$d' | sed 's/^[[:blank:]]*"//g' | sed 's/",[[:blank:]]*$//g' )
			#validTags=$( printf "$cdwTags\n$misceTags\n" | sort | uniq)
			validTags=$(cat ~clay/qa/tags.schema | cut -f 1 -d " " | grep -v "^#")
			invalidTags=$(cat $f | sed 's/^[[:blank:]]*//g' | tr '\t' ' ' | cut -d " " -f 1 | sort | uniq | awk NF | while read line; do if echo "$validTags" | grep -iq "^$line$"; then printf ""; else printf "$color240$line$reset,\n" ; fi; done | grep -v "lab_*" | grep -v "user_*" )
			containsInvalid=$(echo "$invalidTags" | tr ',' '\n' | wc -l)
			echo "	$color240$(ls -lpt --full-time $f | sed 's/ * / /g' | cut -f 6 -d ' ')$reset $color107$f$reset: $(wc -l $f | cut -f 1 -d " ") lines, and has $color107$(cat $f | sed 's/^[[:blank:]]*//g' | tr '\t' ' ' | cut -d " " -f 1 | sort | uniq | awk NF | wc -l)$reset unique tags. $(if [ "$containsNew" -gt "1" ]; then echo "Tags currently not in database: $(echo "$newTags" | sed 's/, $//g')"; fi) $(if [ "$containsInvalid" -gt "1" ]; then echo "Invalid: $(echo "$invalidTags" | tr '\n' ' ' | sed 's/, $//g')"; fi)"
		done
		echo 
		for f in $manifestFiles; do
			echo "	$color240$(ls -lpt --full-time $f | sed 's/ * / /g' | cut -f 6 -d ' ')$reset $color117$f$reset: $(wc -l $f | cut -f 1 -d " ") lines. ($color240$(head -n 1 $f | sed 's/\t/, /g')$reset)"
		done
	}

	clear
	clear

	#########################################################################
	# Usage statement							#
	#########################################################################
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		clear
		echo "

$color240  ┌────────────────────────────────────────────────────────────────────────────┐$reset
    $bg200 Inspect submission $reset                   $color240     github.com/claymfischer/
   ────────────────────────────────────────────────────────────────────────────$reset
    PURPOSE


	This is used to gather all information about submissions. Just run in
	the submission directory. 

$color240  ├────────────────────────────────────────────────────────────────────────────┤$reset
    USAGE

$color240	$ ${color25}whatHappened$reset

	Any additional arguments will enable column-color coding.

$color240	$ ${color25}whatHappened ${color117}anything can go here$reset 

$color240 └────────────────────────────────────────────────────────────────────────────┘$reset
"
		exit 0
	fi

	#########################################################################
	# This is all based on the current directory you are in. Gather some details.
	#########################################################################
	CURRENTDIR=$(echo $PWD | rev | cut -f 1 -d '/' | rev); 
	currentDirId=$(hgsql cdw -N -e "select submitDirId from cdwSubmit where url like '%$CURRENTDIR%' order by id DESC LIMIT 1" | sed 's/\n//g' )
	numberOfSubmissions=$(hgsql cdw -N -e "select count(*) from cdwSubmit where url like '%$CURRENTDIR%';")

	#########################################################################
	# Before we continue, test if any submissions have happened from this directory
	#########################################################################
	submissionsExist="select * from cdwSubmit where url like '%$CURRENTDIR%'"
	continue=$(hgsql cdw -e "$submissionsExist" | wc -l | cut -f 1 -d ' ')
	if [ "$continue" -gt "1" ]; then

		echo
		echo "Looking for all data related to the $bg25 $numberOfSubmissions submissions $reset from your current directory ($bg25 $CURRENTDIR/ $reset, submitDirId $color25$currentDirId$reset)"
		echo 
		#########################################################################
		# Make a custom cdwSubmit query with subqueries. For instance, I'd like
		# to know the name of the tag storm submitted each time, and show more
		# human-readable time and data size.
		#########################################################################
		errorMessageLength=20
		if [ -n "$1" ]; then
			errorMessageLength=1000
		fi
		submitted="SET @rank=0; select @rank:=@rank+1 AS '#',id,TRIM(LEADING 'local://localhost//data/cirm/submit/' from (TRIM(LEADING 'local://localhost//data/cirm/wrangle/$CURRENTDIR/' FROM url))) as url,(SELECT submitFileName from cdwFile where id = cdwSubmit.metaFileId) as metaFile,(SELECT cdwFileName from cdwFile where id = cdwSubmit.metaFileId) as cdwFileName,IF(YEAR(FROM_UNIXTIME(startUploadTime)) = YEAR(CURDATE()),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %k:%i %p'),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %Y %k:%i %p')) as startUploadTime,IF(YEAR(FROM_UNIXTIME(endUploadTime)) = YEAR(CURDATE()),DATE_FORMAT(FROM_UNIXTIME(endUploadTime), '%b %d %k:%i %p'),DATE_FORMAT(FROM_UNIXTIME(endUploadTime), '%b %d %Y %k:%i %p'))  as endUploadTime,userId,manifestFileId,metaFileId,SubmitDirId,fileCount,oldFiles,newFiles,concat(round(byteCount/1024/1024/1024,2),' GB') as byteCount, concat(round(oldBytes/1024/1024/1024,2),' GB') as oldBytes,concat(round(newBytes/1024/1024/1024,2),' GB') as newBytes,SUBSTRING(errorMessage,1,$errorMessageLength) as errorMessage,(SELECT count(*) from cdwFile where submitId = cdwSubmit.id and errorMessage IS NOT NULL and errorMessage<>'') as invalid,fileIdInTransit,metaChangeCount,wrangler from cdwSubmit where url like '%$CURRENTDIR%' ORDER BY id ASC;"
		# distinctSubmitted="select distinct(TRIM(LEADING 'local://localhost//data/cirm/wrangle/' FROM url)) as url,MAX(id) as id ,MAX(IF(YEAR(FROM_UNIXTIME(startUploadTime)) = YEAR(CURDATE()),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %k:%i %p'),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %Y %k:%i %p'))) as startUploadTime,MAX(wrangler) from cdwSubmit where url NOT LIKE 'local://localhost//data/cirm/submit/%' AND submitDirId = $currentDirId group by url order by id ASC"
		# select t1.url,t1.id,t1.wrangler,t1.startUploadTime from cdwSubmit t1 where t1.id = (select t2.id from cdwSubmit t2 where t2.wrangler = t1.wrangler order by t2.id DESC LIMIT 1) order by id
		# select t1.url,t1.id,t1.wrangler,FROM_UNIXTIME(t1.startUploadTime) from cdwSubmit t1 where t1.id = (select t2.id from cdwSubmit t2 where t2.url = t1.url and submitDirId = 3 order by t2.id DESC LIMIT 1) order by id ASC
		distinctSubmitted="select t1.id,TRIM(LEADING 'local://localhost//data/cirm/submit/' from (TRIM(LEADING 'local://localhost//data/cirm/wrangle/$CURRENTDIR/' from t1.url))) as url,t1.wrangler,IF(YEAR(FROM_UNIXTIME(startUploadTime)) = YEAR(CURDATE()),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %k:%i %p'),DATE_FORMAT(FROM_UNIXTIME(startUploadTime), '%b %d %Y %k:%i %p')) as startUploadTime from cdwSubmit t1 where t1.id = (select t2.id from cdwSubmit t2 where t2.url = t1.url and submitDirId = $currentDirId order by t2.id DESC LIMIT 1) order by id ASC"
		#########################################################################
		# Make it so when using a small laptop screen, you could color-code the 
		# output from above so it takes up less screen real estate.
		#########################################################################
		if [ -n "$1" ]; then 
			echo $WALL
			echo
			echo "$bg25 SUBMISSIONS $reset"
			echo
			hgsql cdw -e "$submitted" | sed 's/\t/ | /g' | ~clay/ontogeny/bin/ontogeny_columnColorizer.sh "|" #| tail -n +4 | sed '$d' | sed '$d' | sed '$d'
			echo
		#	hgsql cdw -e "$distinctSubmitted" | sed 's/\t/ | /g' | ~clay/ontogeny/bin/ontogeny_columnColorizer.sh "|" #| tail -n +4 | sed '$d' | sed '$d' | sed '$d'
		#	echo
		else
			echo
			echo "$bg25 ALL SUBMISSIONS $reset"
			echo
			hgsql cdw -e "$submitted"
		fi
		echo
		echo "${color25}Most recent submissions for each manifest$color240"
		hgsql cdw -e "$distinctSubmitted"
		echo "$reset"
		echo $WALL

		#########################################################################
		# DISTINCT(userId) may be useful
		#########################################################################
		userIdQuery="SELECT userId FROM cdwSubmit WHERE url LIKE '%$CURRENTDIR%' ORDER BY id DESC limit 1"
		userId=$(hgsql cdw -e "$userIdQuery" | tail -n +2)
		userIdsQuery="SELECT distinct(userId) FROM cdwSubmit WHERE url LIKE '%$CURRENTDIR%'"
		userIds=$(hgsql cdw -N -e "$userIdsQuery")
		#########################################################################
		# TO be robut, be aware there may be situations with more than one submitter-email
		#########################################################################
		#userIds=$(echo "$userId" | wc -l | cut -f 1 -d ' ')
		#if [ "$userIds" -gt "1" ]; then
		#	$userId=""
		#fi
		userEmailQuery="SELECT email FROM cdwUser WHERE id = $userId"
		userEmail=$(hgsql cdw -e "$userEmailQuery" | tail -n +2 | tr '\n' ' ' | sed 's/ //g')

		for O in $(echo "$userIds"); do
			userIds2="$userIds2 id = $O OR"
		done
		processedUserIds=$(echo "$userIds2" | sed 's/OR$//g')
		#echo "$userIds" | while read line; do userIds2="$userIds2 id = $line OR"; done
		#echo "$userIds2"

		userEmailsQuery="SELECT email FROM cdwUser WHERE $processedUserIds"
		userEmails=$(hgsql cdw -e "$userEmailsQuery" | tail -n +2 | tr '\n' ' ')

		groupIdQuery="select primaryGroup from cdwUser where id = $userId"
		groupId=$(hgsql cdw -e "$groupIdQuery" | tail -n +2)

		groupNameQuery="select name from cdwGroup where id = $groupId"
		groupName=$(hgsql cdw -e "$groupNameQuery" | tail -n +2)

		prepublicationAccessQuery="select distinct(userId) from cdwGroupUser where groupId = $groupId;"
		prepublicationAccess=$(hgsql cdw -e "$prepublicationAccessQuery" | tail -n +2 | while read line; do hgsql cdw -e "select email from cdwUser where id = $line" | tail -n +2 | tr '\n' ' '; done)

		dataSetIdsQuery="select distinct(data_set_id) from cdwFileTags where submit_dir like '%$CURRENTDIR%'"
		dataSetIds=$(hgsql cdw -e "$dataSetIdsQuery" | tail -n +2) # There may be multiple

		lastSubmissionIdQuery="select MAX(id) from cdwSubmit where url like '%$CURRENTDIR%'"
		lastSubmissionId=$(hgsql cdw -e "$lastSubmissionIdQuery" | tail -n +2)

		lastMetaQuery="SELECT submitFileName from cdwFile WHERE submitId = $lastSubmissionId AND submitFileName LIKE '%meta%' ORDER BY id ASC;"
		lastMeta=$(hgsql cdw -e "$lastMetaQuery" | tail -n +2)

		#lastMetaQuery="SELECT submitId,submitFileName from cdwFile where id = (select MAX(id) from cdwFile where submitDirId = $currentDirId and submitFileName LIKE '%meta%')"
		lastMetaQuery="SELECT submitId,submitFileName from cdwFile where id = (select metaFileId from cdwSubmit where submitDirId = $currentDirId order by id DESC limit 1);"
		lastMeta=$(hgsql cdw -e "$lastMetaQuery" | tail -n +2 | cut -f 2)
		lastMetaSubmitId=$(hgsql cdw -e "$lastMetaQuery" | tail -n +2 | cut -f 1)
		lastMetaFileId=$(hgsql cdw -e "select id from cdwFile where submitId = $lastMetaSubmitId and submitFileName like '%meta%';" | cut -f 2 | tr '\n' ' ' | sed 's/ //g' | sed 's/id//g' )

		#lastManifestQuery="SELECT submitId,submitFileName from cdwFile where id = (select MAX(id) from cdwFile where submitDirId = $currentDirId and submitFileName LIKE '%mani%')"
		lastManifestQuery="SELECT submitId,submitFileName from cdwFile where id = (select manifestFileId from cdwSubmit where submitDirId = $currentDirId order by id DESC limit 1);"
		lastManifest=$(hgsql cdw -e "$lastManifestQuery" | tail -n +2 | cut -f 2)
		lastManifestSubmitId=$(hgsql cdw -e "$lastManifestQuery" | tail -n +2 | cut -f 1)
		lastManifestFileId=$(hgsql cdw -e "select id from cdwFile where submitId = $lastManifestSubmitId and submitFileName like '%mani%';" | cut -f 2 | tr '\n' ' ' | sed 's/ //g' | sed 's/id//g' )

		#########################################################################
		#
		#
		#
		#
		#########################################################################
		echo "$bg25 USERS AND GROUPS $reset"
		echo
		echo "	The submitter email(s): $color201$userEmails$reset" # ($color240> $userIdQuery$reset) ($color240> $userEmailQuery$reset)"
		echo "	The primary group of the most recent submitter email ($userEmail) is $color25$groupName$reset (groupId $color25$groupId$reset), which allows prepublication access to:" # $color201$prepublicationAccess$reset"
		echo "		$color201$prepublicationAccess$reset" | sed 's/ /\n\t\t/g'
		if [ "$dataSetIds" == "$CURRENTDIR" ]; then
			datasetmatch=""
		else
			datasetmatch="$bg196 data_set_id ($dataSetIds) does not match directory name ($CURRENTDIR) $reset"
		fi

		#########################################################################
		#
		#
		#
		#
		#########################################################################
		echo $WALL
		echo "$bg25 MANIFEST AND META (SUBMITTED) $reset"
		echo
		echo "	The most recent ${color107}tag storm$reset submitted was named $color107$lastMeta$reset (cdwFile $color107$lastMetaFileId$reset, from submission $color107$lastMetaSubmitId$reset)"
		echo "	The most recent ${color117}manifest$reset submitted was named $color117$lastManifest$reset (cdwFile $color117$lastManifestFileId$reset, from submission $color117$lastManifestSubmitId$reset)"
		echo "	The data_set_id(s) associated: $color202$dataSetIds$reset $datasetmatch" 


		DONTLIST="%fastq.gz% %.fq.gz% analysis/% %.bam% %.bai% %.vcf% %.pdf %.csv %.png %.tar %.json %.html %fastqc_% %.tsv %multianno% %.bw %.jpg %.bw %.bigwig %.results %Picard% %.out %.tab"
		FILTERED=
		for item in $DONTLIST; do
			FILTERED="$FILTERED submitFileName NOT LIKE '$item' AND "
		done
		echo
		echo "	Here are potentially relevant files submitted from this directory:"
		echo 
		hgsql cdw -e "select submitId,submitFileName,id from cdwFile where $FILTERED submitDirId = $currentDirId order by id;"
		echo
		echo "	Here's a distinct list of the above files:" 
		printf "\n\t"
		hgsql cdw -N -e "select distinct(submitFileName) from cdwFile where $FILTERED submitDirId = $currentDirId ORDER BY submitId;" | tr '\n' ',' | sed 's/,/, /g' | sed 's/, $//g'
		echo
		echo

		#########################################################################
		# Show tags, lab tags and cv. Make it short but sweet...
		# Show non-valid tags. 
		#
		#
		#########################################################################



		#########################################################################
		#
		#
		#
		#
		#########################################################################
		echo $WALL
		echo "$bg25 MANIFEST AND META (CURRENT FILES) $reset"
		echo
		validateFiles
		echo 

		#########################################################################
		#
		#########################################################################
		echo $WALL
		echo "$bg25 $ ~ceisenhart/bin/x86_64/cdwCheckDataset stdout $reset"
		echo $color240
		~ceisenhart/bin/x86_64/cdwCheckDataset stdout | ~clay/ontogeny/bin/ontogeny_columnColorizer.sh "|"
		echo
		
		#########################################################################
		# Could print out this only if something is actually found?		#
		#########################################################################
		echo $WALL
		echo "$bg25 $ ~ceisenhart/bin/x86_64/cdwCheckValidation status ${userEmail} stdout $reset"
		echo
		#echo  $color240
		~ceisenhart/bin/x86_64/cdwCheckValidation status $userEmail stdout
		echo
		echo "For more complete information about a submission, try:"
		echo "$color240	cdwCheckValidation status ${userEmail} stdout -submitId=${bg240}$color255$lastSubmissionId$reset$color240 -long$reset"
		echo
		echo "To retry failed file validation, try:"
		echo "$color240	~ceisenhart/bin/x86_64/cdwCheckValidation retry ${userEmail} -submitId=${bg240}$color255$lastSubmissionId$reset$color240 stdout$reset"
		echo
		#########################################################################
		#
		#########################################################################
		echo $WALL
		echo
		echo "	To resubmit, perhaps try:		$color240 ~kent/bin/x86_64/cdwSubmit ${userEmail} maniFastq.txt meta.txt -update -noRevalidate -test $reset"
		echo
		echo "	To see md5sums, perhaps try:		$color240 hgsql cdw -e 'select md5,submitFileName from cdwFile where submitDirId = $currentDirId order by submitFileName;'$reset"
		echo
		echo "	To see file a list of files, try:	$color240 hgsql cdw -e \"SET @rank=0; select @rank:=@rank+1 AS '#', id,submitId,submitFileName,cdwFileName,md5,(select groupId from cdwGroupFile where cdwGroupFile.fileId = id limit 1) from cdwFile where submitDirId=$currentDirId order by id ASC\"$reset"
		echo "						 To clean up, pipe to $color240	| cut -f 4,5,6 | sed 's/raw\///g' | sed 's/201[[:digit:]]\/[[:digit:]]*\/[[:digit:]]*\///g' | formatted"
		echo
		echo "	To give a list to the lab:		$color240 hgsql cdw -e 'SET @rank=0; select md5,submitFileName,cdwFileName,round(size/1024/1024,1) as megabytes from cdwFile where submitDirId=$currentDirId order by id ASC'$reset"
		echo 
		echo "To see the full table of submissions:"
		echo "hgsql cdw -e \"$submitted\" | formatted | less -RS"
		echo
	else 
		echo
		echo "It appears there aren't any submissions related to this directory. We will instead validate tag storm and manifest files, if any are found."
		echo
		validateFiles
		echo  $reset $reset
	fi




