# biotools

This is a repository of some bash shell scripts I have put together while working with biological data on UNIX/Linux servers. I try and maintain cross-platform compatibility where possible. 

The optional installer will create a directory and add the shell scripts to it, update your bash startup file extending your $PATH to access the new binaries, and add some useful aliases.

## hilite.sh


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
