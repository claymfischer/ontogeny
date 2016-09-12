# ontogeny tools

Ontogeny tools are designed for biologists with no background in bioinformatics. They use a lot of color and simplicity on the command line to make the transition from wet lab to computer lab more manageable.

They are bash shell scripts I have put together while working with biological data on UNIX/Linux servers. I try and maintain cross-platform compatibility where possible. 

## installation

The optional installer will create a directory and add the shell scripts to it, update your bash startup file extending your $PATH to access the new binaries, and add some useful aliases.

## conventions

The head of each file contains any information you need to worry about.

```bash
#!/usr/bin/env bash

#################################################################################
# https://github.com/claymfischer
# script.sh
#################################################################################

###############################################################################
# Purpose                                                                     #
###############################################################################
# This script will...

###############################################################################
# Usage                                                                       #
###############################################################################
$ command options

###############################################################################
# Limitations                                                                 #
###############################################################################
# This script cannot accept stdin, it must use files as input.

###############################################################################
# Configuration                                                               #
###############################################################################
# This is the only part you can edit.
USER=clay
PATH=$HOME
# This contains the color library
SOURCE ~/bin/library.sh

```

## hilite.sh

![Example highlighting](/images/highlight/highlight.sh.png)

**Input:** `stdin` `file`

`$ highlight file pattern1 pattern2 ... pattern*n*`

Where `file` can take advantage of filename expansion:

`$ highlight *.txt pattern1 pattern2 ... pattern*n*`

Or just be multiple files:

`$ highlight "file.txt file2.txt" pattern1 pattern2 ... pattern*n*`

Adding multiple files will filter to only lines containing all the patterns.


## colorColumns.sh


## fastq.sh




## transfer.sh

This is a simple script that generates a quick SCP command to download 


## newLs.sh



## about.sh

## list.sh


## checkTags.sh

This gives a summary of a relational-alternative, or ra, file. An ra file establishes a record as a set of related tags and values in a blank line-delimited stanza. Indented stanzas inherit parent stanzas, and can overrite parent settings. These are more human-readable than tab-separated files, and less redundant as parent stanzas can convey tags and values shared with the rest of the file.

If an md5sum file is present, it will also validate that there are no collisions.
