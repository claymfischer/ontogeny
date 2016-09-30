# about the ontogeny toolkit

Ontogeny tools are designed for biologists with no background in bioinformatics. They use a lot of color and simplicity on the command line to make the transition from wet lab to computer lab more manageable. 

The name *ontogeny* refers to the development of an individual from embryo to maturity. I chose this name as my hope is these tools help you to go from terrified of a command line to proficient in bioinformatics.

They are bash shell scripts put together as I learn, working with biological data on UNIX/Linux servers (data wrangling). I try and maintain cross-platform compatibility where possible. 

They follow [kent](https://github.com/ucscGenomeBrowser/kent) command conventions. This means executing the command with no arguments will show usage/help. Many also follow UNIX conventions with the -h or --help flags.

---

Most UNIX software is designed to be [minimimalist](https://en.wikipedia.org/wiki/Unix_philosophy). This is ideal for UNIX power tools, as it makes dealing with data easier in pipelines. 

On the other hand, most of my software is not designed to be part of a pipeline. These tools were designed to format the data for non-programmers to read more easily. Output tends to have columns formatted to align, lots of color, and spacing on the top, left and bottom. This would throw a wrench in the gears of most data pipelines.

---

1. <a href="#Contribute">Contribute</a>
2. <a href="#General">General purpose software</a>
2. <a href="#toolkit">ontogeny_toolkit.sh (extensions to your bash startup file)</a>
3. <a href="#Specific">Specific-use software</a>
4. <a href="#Installation">Installation</a>

---
<a name="Contribute"></a>
# Contribute

This largely hasn't been tested on systems other than CentOS. For instance, my Mac OS laptop uses a different `grep` from the servers I work on, and the Mac OS terminal does not color things with `echo`, only with `printf`. 

Portability is important and needs work. Ensuring consistent usage statements (and -h and --help flags) also needs work.

`$ git pull`

`$ vi file.txt`

`$ git add file.txt`

`$ git commit -m "Adding file.txt"`

`$ git diff --stat --cached origin/master`

`$ git push`

---
<a name="General"></a>
# General purpose software

This software is not specific to internal work projects, and much of it can be employed for any general command-line use. 

1. <a href="#highlight">Highlight</a>
2. <a href="#columns">Color-code columns</a>
3. <a href="#sequence">Color-code sequence data</a>
4. <a href="#transfer">Transfer files</a>
5. <a href="#newls">New ls</a>
6. <a href="#about">About</a>
7. <a href="#contents">List contents</a>
7. <a href="#prompt">Change your command prompt for no good reason</a>

<a name="highlight"></a>
## Highlight

Highlight any number of search patterns with a variety of colors. Can accept **stdin** (piped input) or use files, and can pipe out (for example to `less -R`). It also has extensive **regex** support. Protips and specifics are available in the [usage](https://github.com/claymfischer/ontogeny/blob/master/images/highlight/highlight_usage.png?raw=true).

![Example highlighting](/images/highlight/highlight.sh.png)

**Input:** `stdin` `file.txt` `"multiple.txt files.txt"` `file.*`

`$ highlight file pattern1 pattern2 ... pattern{n}`

Where `file` can take advantage of filename expansion, be multiple files, or just stdin:

`$ highlight *.txt pattern1 pattern2 ... pattern*n*`

`$ highlight "file.txt file2.txt" pattern1 pattern2 ... pattern*n*`

`$ cat file.txt | grep pattern1 | highlight stdin pattern2 pattern3 | less -R`

> Note: adding multiple files will *filter* to only lines containing all the patterns. You can trick it to filter withinin a single file by also including the empty file `/dev/null`, for example: `$ highlight "/dev/null file.txt" pattern1 pattern2`

---
<a name="columns"></a>
## Color-code columnar data

In bioinformatics we deal with the lowest common denominator format for data, which is generally plain text in tab-separated columns. These tab-separated columns are computer-readable moreso than human-readable, as the columns do not line up. It can be difficult to tell which column you are looking at when you have a screen of line-wrapped text.

This takes advantage of a simple `grep` loop to color-code the columns.

`$ cat example.tsv`

![Example column coloring](/images/columns/columns_example2.png)

`$ columns example.tsv`

![Example column coloring](/images/columns/columns_example2_colored.png)

--- 
<a name="sequence"></a>
## Color-code sequence and quality score data

Color-codes bases in a gzipped fastq file.

`$ fastq SRR123.fastq.gz`

![Example fastq color-coding](/images/fastq/fastq.png)

You can also color-code the quality score. Set any third argument.

`$ fastq SRR123.fastq.gz x`

![Example fastq color-coding](/images/fastq/fastq_quality.png)

--- 
<a name="transfer"></a>
## Quickly transfer files to-and-from your server

This is a simple script that generates a color-coded SCP command to upload or download files.

![Example transfer](/images/transfer/transfer.png)

`$ transfer file1.txt file2.txt ... file{n}.txt`

It also takes advantage of filename expansion

` $ transfer *.txt`

--- 
<a name="newls"></a>
## New ls and new list

This lists directories first, then files. It can color-code different types of files.

If you are new to shell scripting, these are a fantastic example to begin modifying.

![Example transfer](/images/new_ls/new_ls.png)
![Example transfer](/images/new_ls/new_list.png)

--- 
<a name="about"></a>
## About

This will tell you about any file or directory. It has lazy usage, or more verbose usage that allows detailed previews of the file. 

*This was my first shell script, and really is not a great example of code. However, it's fast and it does what it needs so I've never updated it.*

### About files

It will tell you file size, encoding (ASCII or non-ASCII), when the file was last modified in human terms (seconds, minutes, days, weeks, months, years), how many lines it has (and of those, how many are non-blank and how many are actual content, not comments), how many columns (default delimiter is a tab, but you can set it). It also previews the head and foot of a file. 

![Example about](/images/about/about_file.png)

`$ about file.txt`

### About directories

Gives you the real and apparent size of directory (eg. if transferring the contents over a network), the number of files in the top level as well as in all subdirectories, when the directory was last modified, any file extensions and examples with those extensions, and groups files by date modified.

![Example about](/images/about/about_directory.png)

--- 

<a name="contents"></a>
## List contents

This is an extension of a script I found in 'Wicked Cool Shell Scripts.'

![Example contents](/images/contents/contents.png)

--- 

<a name="prompt"></a>
## Change your command prompt

![Example .bashrc aliases](/images/changePrompt/changePrompt.png)

This is a silly piece of software with no practical purpose, it was written as an exercise challenge when learn bash shell scripting.

It allows you to change your command prompt to any character. It can give you a new character at each prompt, or keep the same character, or return you to your old command prompt when done.

--- 
<a name="toolkit"></a>
# ontogeny_toolkit.sh - extension to your .bashrc

The `ontogeny_toolkit.sh` extends your `.bashrc` by adding aliases to the above software and adding the following functionality:

1. <a href="#screen">Screen sessions</a>
2. <a href="#grep">grep help</a>
3. <a href="#nonascii">Highlight non-ascii characters</a>
4. <a href="#whichcolumns">Decipher which column number has your data of interest</a>
5. <a href="#writing">Test if current directory is actively writing</a>
6. <a href="#tmp">Make better tmp directories</a>
7. <a href="#cleanUp">Visually locate multiple spaces/tabs</a>
8. <a href="#format">Align your columns so they're easier to read</a>

---
<a name="screen"></a>
Screen sessions change your prompt to alert you that you're in a screen session, and tell you the name of it.

![Example .bashrc aliases](/images/aliases/screen.png)

You can also invoke help either in the screen session or on the command line for a quick refresher, as well as to see a list of screens screens.

![Example .bashrc aliases](/images/aliases/screenHelp.png)

<a name="grep"></a>
Since `grep` is such an important tool for bioinformaticians to learn, there's also a `howtogrep` refresher.

![Example .bashrc aliases](/images/aliases/howtogrep.png)

<a name="nonascii"></a>
Check if a file has non-ascii characters

![Example .bashrc aliases](/images/aliases/ascii.png)

![Example .bashrc aliases](/images/aliases/nonascii.png)

<a name="whichcolumns"></a>
Figure out which column number you need.

![Example .bashrc aliases](/images/aliases/whichColumn.png)

This way will preview the second line of the file to help you confirm it's the correct column.

![Example .bashrc aliases](/images/aliases/whichColumns.png)

<a name="writing"></a>
Test if your current directory is actively writing anything.

![Example .bashrc aliases](/images/aliases/writing.png)

<a name="tmp"></a>
If you find yourself making a lot of `tmp` `temp` or `foo` directories and getting them mixed up, here are a few commands to make a unique directory that you can keep track of.

![Example .bashrc aliases](/images/aliases/mkdir.png)

<a name="cleanUp"></a>
Visually inspect for multiple spaces or tabs where they shouldn't be. ` cat file.txt | cleanUp `

![Example .bashrc aliases](/images/aliases/cleanUp.png)

<a name="format"></a>
Tab-separated data can be difficult to read if the rows vary in character length. Here's an example of using the format alias. 
Note that to align this, a character needs to be placed in columns or rows with blanks. This will insert a period (.) character. Seeing it aligned can be easier to read than coloring the columns.

![Example .bashrc aliases](/images/aliases/format_plain.png)

![Example .bashrc aliases](/images/aliases/format_formatted.png)

It's even easier to read than the color-coded `column` program from above:

![Example .bashrc aliases](/images/aliases/format_colored.png)

--- 
<a name="Specific"></a>
# Specific use software

The following software is developed for specific use in data wrangling work. I do keep a repository of it here so we can all collaboratively develop (and the source code may be useful to some), but it is unlikely to find general-purpose use.

A lot of this software is designed to work for:

**ra file, or tag storm**

An ra (relational-alternative) file establishes a record as a set of related tags and values in a blank line-delimited stanza (block of text). Parent stanzas convey tags and values shared with the rest of the file. Indented stanzas inherit parent stanzas, and can override parent settings. 

These are designed to be human-readable, and reduce redundancy of tab-separated files.

**manifest file**

This is a list of files with a unique identifer to link the file with metadata about it. Tab separated columns.

**spreadsheets**

In collaborating with off-site folks who are not familiar with the command-line, it can often be easier to share Google Sheets or Excel Spreadsheets. There is some software to generate input for spreadsheets.

1. Check submission
2. Generate spreadsheet input
3. Generate a tag storm summary
4. Generate a tag summary

---

## Check submission

This gives a summary of a relational-alternative, or ra, file. 

If an md5sum file is present, it will also validate that there are no collisions and compare it to the md5sum file.

![checkSubmission](/images/checkSubmission/checkSubmission.png)

--- 

## Generate spreadsheet input

This takes a tag storm as input, does some calculations and gives a tab-separated output for importing into a tag reconciliation spreadsheet.

![generate spreadsheet input](/images/spreadsheetInput/spreadsheetInput.png)

---

## Generate a tag storm summary

This gives you a tag-by-tag count of values and totals them for you. Very useful for a high-level look at a tag storm.

![tagStormSummary](/images/tagStormSummary/tagStormSummary.png)

---

## Generate a tag summary

This gives a summary of a tag from a tag storm, providing counts and showing all the different values and the stanza indentation for each.

![tagSummary](/images/tagSummary/tagStormSummary.png)

---

# Colors

![colors](/images/palette_fg.png)

![colors](/images/palette_bg.png)


![colors](/images/gradients.png)

---
<a name="Installation"></a>
# Installation

**Clone**

First you need to clone. This will create directory called `ontogeny` wherever you run this command:

`$ git clone https://github.com/claymfischer/ontogeny.git`

**bash startup file**

Add the following to your `.bashrc` and edit the `ONTOGENY_INSTALL_PATH`:
```bash
# Ontogeny repository path:
ONTOGENY_INSTALL_PATH=/path/to/the/repository
source $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh
```

**make**

Next, users will be able to simply `make install` from the repository directory to copy executables to where they need to be.
