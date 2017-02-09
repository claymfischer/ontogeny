# About the ontogeny toolkit

Ontogeny tools are designed for biologists with no background in bioinformatics. They use a lot of color and simplicity on the command line to make the transition from wet lab to computer lab more manageable. 

<details>
<summary>Learn more</summary>

The name *ontogeny* refers to the development of an individual from embryo to maturity. I chose this name as my hope is these tools help you to go from terrified of a command line to proficient in bioinformatics.

They are bash shell scripts cobbled together while learning how to work with biological data on UNIX/Linux servers (data wrangling).

They follow [kent](https://github.com/ucscGenomeBrowser/kent) command conventions. This means executing the command with no arguments will show usage/help. Most also follow UNIX/Linux conventions by showing usage when run with the `-h` or `--help` flags.

---

Most UNIX software is designed to be [minimimalist](https://en.wikipedia.org/wiki/Unix_philosophy). This is ideal for UNIX power tools, as it makes dealing with data easier in pipelines. 

On the other hand, most of my software is not designed to be part of a pipeline. These tools were designed to format the data for non-programmers to read more easily. Output tends to have columns formatted to align, lots of color, and spacing on the top, left and bottom. This would throw a wrench in the gears of most data pipelines.

</details>

---

1. <a href="#Contribute">Contribute</a>
2. <a href="#General">General purpose software (standalone scripts)</a>
2. <a href="#toolkit">Ontogeny Toolkit (extensions to your bash startup file)</a>
3. <a href="#Specific">Data Wrangling</a>
4. <a href="#Installation">Installation</a>

---
<a name="Contribute"></a>
# Contribute

`$ git clone https://github.com/claymfischer/ontogeny.git`

`$ vi file.txt`

`$ git pull`

`$ git add file.txt`

`$ git commit -m "Adding file.txt"`

`$ git diff --stat --cached origin/master`

`$ git log --stat --pretty=short --graph`

`$ git push`

---
<a name="General"></a>
# General purpose software

This software is not specific to internal work projects, and much of it can be employed for any general command-line use. 

1. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_highlight.sh) <a href="#highlight">Highlight</a>
2. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_columns.sh) <a href="#columns">Color-code columns</a>
3. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_fastq.sh) <a href="#sequence">Color-code sequence data</a>
4. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_transfer.sh) <a href="#transfer">Transfer files</a>
5. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_newLs.sh) [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_list.sh) <a href="#newls">New ls and list</a>
6. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_about.sh) <a href="#about">About</a>
7. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_contents.sh) <a href="#contents">List contents</a>
7. [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_changePrompt.sh) <a href="#prompt">Change your command prompt for no good reason</a>

<a name="highlight"></a>
## Highlight
 [[view source]](https://github.com/claymfischer/ontogeny/blob/master/bin/ontogeny_highlight.sh)
 
Highlight any number of search patterns with a variety of colors. Can accept **stdin** (piped input) or use files, and can pipe out (for example to `less -R`). It also has extensive **regex** support. Protips and specifics are available in the [documentation and usage](https://github.com/claymfischer/ontogeny/blob/master/docs_highlight.md).


`$ highlight file.txt pattern1 pattern2 ... pattern{n}`

![Example highlighting](/images/highlight/highlight.sh.png)

<details>
<summary>Learn more</summary>

**Input:** `stdin` `pipedinput` `file.txt` `"multiple.txt files.txt"` `file.*`

Input examples: 

`$ highlight *.txt pattern1 pattern2 ... pattern*n*`

`$ highlight "file.txt file2.txt" pattern1 pattern2 ... pattern*n*`

`$ cat file.txt | grep pattern1 | highlight stdin pattern2 pattern3 | less -R`

`$ cat file.txt | grep pattern1 | highlight pipedinput pattern2 pattern3 | less -R`

`pipedinput` and `stdin` are both the same, but `stdin` will show you a color legend of what you're highlighting.

> Note: adding multiple files will *filter* to only lines containing all the patterns. You can trick it to filter withinin a single file by also including the empty file `/dev/null`, for example: `$ highlight "/dev/null file.txt" pattern1 pattern2`

As this can handle any number of patterns (and will color them randomly with 256 colors), it's useful for a lot of QA purposes, making visual connections easier. For example, you could use command substitution to generate your pattern list:

`$ highlight file.txt $( cat listOfAssemblyNames.tsv | cut -f 2 | awk NF | sort | uniq | tr '\n' ' ' )`

> Note: there are patterns with special meaning, such as `CLEANUP` to help location errant tabs and spaces in biological data storage.

</details>

---
<a name="columns"></a>
## Color-code columnar data

In bioinformatics we deal with the lowest common denominator format for data, which is generally plain text in tab-separated columns. These tab-separated columns are computer-readable moreso than human-readable, as the columns do not line up. It can be difficult to tell which column you are looking at when you have a screen of line-wrapped text.

This takes advantage of a simple `grep` loop to color-code the columns. Accepts `stdin`, you'll need to provide the argument `stdin` instead of `file.tsv`. There are color legends both at the top at bottom, allowing you to pipe to `head` or `tail`.

`$ cat example.tsv`

![Example column coloring](/images/columns/columns_example2.png)

`$ columns example.tsv`

![Example column coloring](/images/columns/columns_example2_colored.png)

<details>
<summary>Learn more</summary>

Any additional arguments will color specific columns for comparison. This example also shows how to use `stdin`.

`$ cat example.tsv | columns stdin 3 6 9 10 17 25`

![Example column coloring](/images/columns/column_comparisons.png)

</details>

--- 

<details>
<summary>Additional software</summary>

<a name="sequence"></a>
## Color-code sequence and quality score data

Color-codes bases in a gzipped fastq file.

`$ fastq SRR123.fastq.gz`

![Example fastq color-coding](/images/fastq/fastq.png)

<details>
<summary>Learn more</summary>

You can also color-code the quality score. Set any third argument.

`$ fastq SRR123.fastq.gz x`

![Example fastq color-coding](/images/fastq/fastq_quality.png)

</details>

--- 

<a name="newls"></a>
## New ls and new list

This lists directories first, then files. It can color-code different types of files.

If you are new to shell scripting, these are fantastic examples to begin modifying. They were written as tutorials for how to write shell scripts. They are similar, except `list` will also do a line count for text files.

![Example transfer](/images/new_ls/new_ls.png)
![Example transfer](/images/new_ls/new_list.png)

--- 
<a name="about"></a>
## About

This will tell you about any file or directory. It has lazy usage, or more verbose usage that allows detailed previews of the file. 

*This was my first shell script, and really is not a great example of code. However, it's fast and it does what it needs so I've never updated it.*

<details>
<summary>Learn more</summary>
### About files

It will tell you file size, encoding (ASCII or non-ASCII), when the file was last modified in human terms (seconds, minutes, days, weeks, months, years), how many lines it has (and of those, how many are non-blank and how many are actual content, not comments), how many columns (default delimiter is a tab, but you can set it). It also previews the head and foot of a file. 

![Example about](/images/about/about_file.png)

`$ about file.txt`

### About directories

Gives you the real and apparent size of directory (eg. if transferring the contents over a network), the number of files in the top level as well as in all subdirectories, when the directory was last modified, any file extensions and examples with those extensions, and groups files by date modified.

![Example about](/images/about/about_directory.png)

</details> 

--- 

<a name="contents"></a>
## List contents

This is an extension of a script I found in 'Wicked Cool Shell Scripts.'

![Example contents](/images/contents/contents.png)

---

<a name="transfer"></a>
## Quickly transfer files to-and-from your server

This is a simple script that generates a color-coded SCP command to upload or download files. It was written as a tutorial in bash shell scripting.

![Example transfer](/images/transfer/transfer.png)

<details>
<summary>Learn more</summary>
`$ transfer file1.txt file2.txt ... file{n}.txt`

It also takes advantage of filename expansion

` $ transfer *.txt`
</details>

---

<a name="prompt"></a>
## Change your command prompt

<details>
<summary>Learn more</summary>

This is a silly piece of software with no practical purpose, it was written as an exercise challenge when learning bash shell scripting.

![Example .bashrc aliases](/images/changePrompt/changePrompt.png)

It allows you to change your command prompt to any character. It can give you a new character at each prompt, or keep the same character, or return you to your old command prompt when done. The prompts chosen requires changing the settings of LC_ALL to allow UNICODE, so will affect `sort` behavior.

</details>

---
<a name="Colors"></a>
# Palette library

If you'd like to start using colors, here is the output from `bin/paletteTest.sh`:

![colors](/images/palette_fg.png)

![colors](/images/palette_bg.png)

![colors](/images/gradients.png)

</details> 

--- 

<a name="toolkit"></a>
# ontogeny_toolkit.sh - extension to your .bashrc

The `ontogeny_toolkit.sh` extends your `.bashrc` by adding aliases to the above software and adding the following functionality:


## Contribute

If you want to contribute some bash functions, there's a library of functions available for handling argument validity (checking if integers, etc), checking for files existing and making suggestions, etc.

The library functions begin with the prefix `lib_`.

## General / introductory help

<details>
<summary>Learn more</summary>

1. <a href="#screen">Screen sessions</a>
2. <a href="#grep">grep help</a>
3. <a href="#tmp">Make better tmp directories</a>

**noWrap**

Run `noWrap` to temporarily halt line wrapping around your terminal. After 20 seconds your terminal is back to default.

**l**

Execute `l` (lowercase L) to list everything in the directory in a more human-readable fashion, including the time stamps. It's a simple alias.

**showMatches**

Run `showMatches file.txt pattern` to show all matches (highlighted) with context. Add another argument to set amount of context you want to include: `showMatches file.txt pattern 10`. Very fast and useful for parsing files with multiple matches, for example looking for a certain type of error in an error logs.

> Note that patterns have extensive regex support

**grabBetween**

This grabs all the content between two patterns: `grabBetween file.txt pattern1 pattern2`

> Note that this will grab the first match of the pattern found, and will ignore further matches.

> Patterns have extensive regex support

**grabLines**

`grabLines file.txt 100 250`

This will return all content between line numbers. 

**checkFastq**

This grabs the content between specific line numbers in a gzipped fastq file. Same usage as `grabLines`.

**fixLastLine**

Pipe to this to fix issues with CRLF lines. Very common with data saved from spreadsheets or text files from Windows PCs.

**fixNewLines**

Pipe to this to fix CRLF lines in a file. Very common with data saved from spreadsheets or text files from Windows PCs.

**deleteBlankLines**

Does what it says, it removes blank lines from a file. Used in a pipe.

**reduceMultipleBlankLines**

This will fix up a file by reducing regions with multiple blank lines to only one blank line.

**reduceMultipleBlankSpaces**

This will clean up a file, reducing areas with more than one space to only one space.


<a name="screen"></a>**screenHelp**

Your prompt will change when entering a `screen` to alert you that you're in a `screen` session.

![Example .bashrc aliases](/images/aliases/screen.png)

You can also invoke help by simply running `screenHelp` either in the screen session or on the command line for a quick refresher. It will also show you a list of running `screen` sessions or the name of your current screen, if in one.

![Example .bashrc aliases](/images/aliases/screenHelp.png)


<a name="grep"></a>
Since `grep` is such an important tool for bioinformaticians to learn, there's also a `howtogrep` refresher.

![Example .bashrc aliases](/images/aliases/howtogrep.png)

<a name="tmp"></a>
If you find yourself making a lot of `tmp` `temp` or `foo` directories and getting them mixed up, here are a few commands to make a unique directory that you can keep track of.

![Example .bashrc aliases](/images/aliases/mkdir.png)

</details>

## Inspecting files and directories

<details>
<summary>Learn more</summary>
1. <a href="#writing">Test if current directory is actively writing</a>
2. <a href="#nonascii">Highlight non-ascii characters</a>

**linesNotEmpty**

Returns number of lines that are not empty or white space.

**linesContent**

Returns number of lines containing content and which so not begin with a hashtag.

<a name="writing"></a>
Test if your current directory is actively writing anything.

![Example .bashrc aliases](/images/aliases/writing.png)

<a name="nonascii"></a>
Check if a file has non-ascii characters

![Example .bashrc aliases](/images/aliases/ascii.png)

![Example .bashrc aliases](/images/aliases/nonascii.png)

<a name="cleanUp"></a>
Visually inspect for multiple spaces or tabs where they shouldn't be. ` cat file.txt | cleanUp `

![Example .bashrc aliases](/images/aliases/cleanUp.png)

</details>



## Tab-separated data

<details>
<summary>Learn more</summary>

1. <a href="#format">Align your columns so they're easier to read</a>
2. <a href="#whichcolumns">Decipher which column number has your data of interest</a>
3. <a href="#cleanUp">Visually locate multiple spaces/tabs</a>

<a name="whichcolumns"></a>**whichColumns**

Figure out which column number you need.

![Example .bashrc aliases](/images/aliases/whichColumn.png)

This way will preview the second line of the file to help you confirm it's the correct column.

![Example .bashrc aliases](/images/aliases/whichColumns.png)

**describeColumns**

`describe file.tsv` Similar to `whichColumns`, in that it provides the column number, column header and first row value for a tab-separated file.

**summarizeColumns**

`summarizeColumns file.tsv` will give a detailed overview of each column and let you know if the column numbers are inconsistent or the file uses Windows-style CRLF line breaks. You can set any delimiter, it defaults to tab. 

> Note that it gives 5 random values from each column so you get an idea of what's going on. You can instruct it to give a specific number of examples, and even truncate each example so they all fix on your screen.

**columnAverage**

`cat file.tsv | cut -f 1 | columnAverage` This will return the average number of characters. This is for piped input, one column of data.

**columnLengths**

`cat file.tsv | columnLengths` This will return the average characters in each column. Used in a pipe.

**numColumns** 

`numColumns file.tsv` Returns the number of columns in a tab-separated file.

**maxColumns** 

`cat file.tsv | maxColumns` Returns the highest number of columns found in a tab-separated file.

**minColumns**

Returns the lowest number of columns found in a tab-separted file.

<a name="format"></a>
###Formatting columnar data to be human-legible

Tab-separated data can be difficult to read if the rows vary in character length. Here's an example of using the format alias. 
Note that to align this, a character needs to be placed in columns or rows with blanks. This will insert a period (.) character. Seeing it aligned can be easier to read than coloring the columns.

![Example .bashrc aliases](/images/aliases/format_plain.png)

![Example .bashrc aliases](/images/aliases/format_formatted.png)

It's even easier to read than the color-coded `column` program from above:

![Example .bashrc aliases](/images/aliases/format_colored.png)


</details>


--- 
<a name="Specific"></a>
# Specific use software

The following software is developed for specific use in data wrangling work. I do keep a repository of it here so we can all collaboratively develop (and the source code may be useful to some), but it is unlikely to find general-purpose use.

<details>
<summary>Learn more about our internal file formats and the software to work with them</summary>

A lot of this software is designed to work for:

**ra file, or Tag Storm**

An ra (relational-alternative) file establishes a record as a set of related tags and values in a blank line-delimited stanza (block of text). Parent stanzas convey tags and values shared with the rest of the file. Indented stanzas inherit parent stanzas, and can override parent settings. 

These are designed to be human-readable, and reduce redundancy of tab-separated files.

**manifest file**

This is a list of files with a unique identifer to link the file with metadata about it. Tab separated columns.

**spreadsheets**

In collaborating with off-site folks who are not familiar with the command-line, it can often be easier to share Google Sheets or Excel Spreadsheets. There is some software to generate input for spreadsheets.

---

1. Check submission
2. Generate spreadsheet input
3. Generate a tag storm summary
4. Generate a tag summary

---

## Check submission

This gives a summary of a relational-alternative, or ra, file. 

If an md5sum file is present, it will also validate that there are no collisions and compare it to the md5sum file.

![checkSubmission](/images/checkSubmission/checkSubmission_fail.png)

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

![tagSummary](/images/tagSummary/tagSummary.png)

</details>

---
<a name="Installation"></a>
# Installation

**Clone**

First you need to clone. This will create directory called `ontogeny` wherever you run this command:

`$ git clone https://github.com/claymfischer/ontogeny.git`

If you want to learn more about `git` and why it is useful when dealing with biological data, I highly recommend the book [Bioinformatics Data Skills](http://proquest.safaribooksonline.com/book/bioinformatics/9781449367480). It has a fantastic chapter on `git` and what you need to know, and explains it in a no-nonsense manner, assuming you have no background in bioinformatics. The entire book is an amazing resource well worth every penny.

**bash startup file**

Add the following to your `.bashrc` and edit the `ONTOGENY_INSTALL_PATH`:
```bash
# Ontogeny repository path:
ONTOGENY_INSTALL_PATH=/path/to/the/repository
source $ONTOGENY_INSTALL_PATH/lib/ontogeny_toolkit.sh
```
Protip: put this at the *top* of your `.bashrc` file. This way it won't override your own settings of the same variables. For instance, if you have a `PS1` set in your .bashrc, it won't get overridden if this is sourced at the top.

**make**

Currently looking into enabling users to simply `make install` from the repository directory to copy executables to where they need to be.
