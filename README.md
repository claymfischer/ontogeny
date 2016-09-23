# ontogeny tools

Ontogeny tools are designed for biologists with no background in bioinformatics. They use a lot of color and simplicity on the command line to make the transition from wet lab to computer lab more manageable.

They are bash shell scripts I have put together while working with biological data on UNIX/Linux servers. I try and maintain cross-platform compatibility where possible. 

They follow [kent](https://github.com/ucscGenomeBrowser/kent) command conventions. This means executing the command with no arguments will show usage/help. Many also follow UNIX conventions with the -h or --help flags.

---

## Highlight

Highlight any number of search patterns with a variety of colors. Can accept **stdin** (piped input) or use files, and can pipe out (for example to `less -R`). It also has extensive **regex** support. Protips and specifics are available in the [usage](https://github.com/claymfischer/ontogeny/blob/master/images/highlight/highlight_usage.png?raw=true).

![Example highlighting](/images/highlight/highlight.sh.png)

**Input:** `stdin` `file`

`$ highlight file pattern1 pattern2 ... pattern{n}`

Where `file` can take advantage of filename expansion, be multiple files, or just stdin:

`$ highlight *.txt pattern1 pattern2 ... pattern*n*`

`$ highlight "file.txt file2.txt" pattern1 pattern2 ... pattern*n*`

`$ cat file.txt | grep pattern1 | highlight stdin pattern2 pattern3 | less -R`

> Note: adding multiple files will *filter* to only lines containing all the patterns.

---

## colorColumns.sh

This takes advantage of a simple `grep` loop to color columns different colors. Very useful when dealing with tab-separated data.

`$ cat example.tsv`

![Example column coloring](/images/columns/columns_example2.png)

`$ columns example.tsv`

![Example column coloring](/images/columns/columns_example2_colored.png)

--- 

## fastq.sh

Color-codes bases in a gzipped fastq file.

`$ fastq SRR123.fastq.gz

![Example fastq color-coding](/images/fastq/fastq.png)

`$ fastq SRR123.fastq.gz x

![Example fastq color-coding](/images/fastq/fastq_quality.png)

--- 

## transfer.sh

This is a simple script that generates a quick SCP command to download 

--- 

## newLs.sh


--- 


## about.sh

--- 

## list.sh

--- 

## checkTags.sh

This gives a summary of a relational-alternative, or ra, file. An ra file establishes a record as a set of related tags and values in a blank line-delimited stanza. Indented stanzas inherit parent stanzas, and can overrite parent settings. These are more human-readable than tab-separated files, and less redundant as parent stanzas can convey tags and values shared with the rest of the file.

If an md5sum file is present, it will also validate that there are no collisions.

--- 

## installation

The optional installer will create a directory and add the shell scripts to it, update your bash startup file extending your $PATH to access the new binaries, and add some useful aliases.

Soon, users will be able to simply `make install` from the repository directory instead.

--- 

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
# Run the command with no arguments for usage.
# Quickstart example:
#       $ command options

###############################################################################
# Limitations                                                                 #
###############################################################################
# This script cannot accept stdin, it must use files as input.

###############################################################################
# Configuration                                                               #
###############################################################################
# This is the only part you can edit.
USER="clay"
PATH=$HOME
# This contains the color library
SOURCE ~/bin/library.sh

```
