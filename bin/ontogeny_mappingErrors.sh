#!/usr/bin/env bash

source ~clay/.bashrc

		mappingErrors() {
			# TO DO ignore commented lines. grep -v $'^#'
			# Handle help/usage
			if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then printf "Usage:\n	mappingErrors manifest.txt meta.txt\n\nIf no files set, assumes maniFastq.txt and meta.txt\n\nThis will let you know if any meta values are duplicated, and let you know which ones don't map between the meta and manifest.\n\n"; return 0; fi
			# Automatically choose manifest and meta files if not supplied
			if [ -z "$1" ]; then manifest="maniFastq.txt"; else manifest=$1; fi
			if [ -z "$2" ]; then tagStorm="meta.txt"; else tagStorm=$2; fi
			# Ensure they actually exist
			if [ ! -f "$manifest" ]; then templateNotFound $1; return 0; fi
			if [ ! -f "$tagStorm" ]; then templateNotFound $2; return 0; fi
			# Figure out which column of the manifest links to the tag storm
			metaColumns=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep $'\smeta$' | wc -l)
			if [ "$metaColumns" -gt 1 ]; then echo "There appears to be multiple meta columns in your manifest. We aren't sure which to use."; return 0; fi
			if [ "$metaColumns" -eq 0 ]; then echo "There appears to be no meta column in your manifest."; return 0; fi
			metaColumn=$(head -1 $manifest | sed 's/\t/\n/g' | nl | grep $'\smeta$' | sed 's/^[[:blank:]]*//g' | cut -f 1)
			# Before we continue, verify there aren't duplicate "meta" values. We need them to be unique. 
			metaDups=$(cat $tagStorm | grep "meta " | cut -f 2 -d " " | sort | uniq -c | sed 's/^[[:blank:]]*//g' | grep ^2)
			if [ -z "$metaDups" ]; then
				inMeta=$(cat $tagStorm | grep "meta " | cut -f 2 -d  " " | sort | uniq )
				inManifest=$(cut -f $metaColumn $manifest | tail -n +2 | sort | uniq )
				echo "$bg196 Missing from $tagStorm $reset"
				echo 
				diff <(echo "$inMeta") <(echo "$inManifest") | grep $'^>' | sed 's/^> //g'
				echo
				echo "$bg202 Missing from $manifest $reset"
				echo
				diff <(echo "$inManifest") <(echo "$inMeta") | grep $'^>'
			else
				echo "$bg196 Duplicate meta values in $tagStorm $reset"
				echo
				echo "	You'll need to resolve these conflicts to continue."
				echo
				echo "$metaDups" | sed 's/^/\t/g'
			fi
			# Output a sed script that matches pattern and can comment out to continue with submission?
			# sed 's/^\(.*$PATTERN.*\)$/#\1/g'
			from=$(cat $manifest | tail -n +2 | cut -f 1 -d "/" | sort | uniq | grep -v ^#)
			if [ "$from" == "raw" ]; then
				printf ""
			else
				printf "\n$bg201 MANIFEST WARNING $reset"
				printf "\n\nThe manifest $color240$manifest$reset links to files outside of the$color240 raw/$reset directory.\n\n"
			fi
		}
mappingErrors
