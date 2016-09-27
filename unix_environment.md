# UNIX Environment

If you're new to UNIX, there are customizations you'll want to make to your environment so your system is more useful.

## startup files

There are a number of startup files I edit. The `bash` startup files are loaded when you first enter your shell. You can either source them to reload, or exit and re-ssh into your account.

Depending on your system and configuration, you may have to deal with `.bashrc`, `.bash_profile`, `.profile` or others - and that's just for bash. If you use a different shell, these don't apply.

**.bashrc**
Generally, you will want to set some of the following:


**.bash_profile**

This file is only loaded up startup in many UNIX environments. 

**.bash_profile (on MacBook)**

On your Mac, the startup file is `.bash_profile` not `.bashrc`.

```bash

################################################################################# 
# MacBook bash startup file configuration                                       #
################################################################################# 

        ######################################################################### 
        # Commonly-accessed servers                                             #
        ######################################################################### 
        alias dev='ssh user@dev.server.edu'
        alias beta='ssh user@beta.server.edu'
        alias gbib='ssh browser@localhost -p password'

        ######################################################################### 
        # Personalize my environment.                                           #
        #########################################################################
        # The PS1 Variable allows us to customize our prompt.
        # time: \A (or \@ will add AM/PM)
        # current directory: \W
        # server: \h
        # user: \u
        # ansi escape sequence color: \e[38;5;240m (240 can be 0-255), to reset use \e[0m 
        # to make sure the CLI knows the size, escape with \[ \] or it will be wonky and broken 
        export PS1='\[\e[38;5;240m\][\A] \[\e[38;5;240m\]\u\[\e[38;5;240m\]@\[\e[38;5;240m\]MacBook \[\e[m\]\[\e[38;5;240m\]\W/\[\e[0m\]\[\e[m\] \[\e[m\]\[\e[38;5;25m\]🍏 \[\e[0m\] '
        
        # I reload my bash startup file often, so made an alias
        alias load='source ~/.bash_profile'
        
        # This is a script from ontogeny tools that I like to use locally.
        alias transfer='~/Documents/bin/ontogeny_transfer.sh'

        ######################################################################### 
        # General UNIX/Linux environment configuration                          #
        ######################################################################### 
        export EDITOR=vi
        export MACHTYPE=x86_64
        export LANG="en_US.UTF-8"
        export LC_COLLATE=C
        # get colors on ls in emacs
        export VISUAL=vi

        # umask line added to allow groups to write to created directories
        # umask 002
        
        ######################################################################### 
        # Let's clear our screen and print out some ascii art. I use different  #
        # colors/art on different servers as a quick visual reminder.           #
        ######################################################################### 
        clear
        color25=$(printf "\e[38;5;25m")
        reset=$(printf "\e[0m")
        echo "$color25"
cat << 'EOF'

    `-:-.   ,-;"`-:-.   ,-;"`-:-.   ,-;"`-:-.   ,-;"
        `=`,'=/     `=`,'=/     `=`,'=/     `=`,'=/
         y==/        y==/        y==/        y==/
       ,=,-<=`.    ,=,-<=`.    ,=,-<=`.    ,=,-<=`.
    ,-'-'   `-=_,-'-'   `-=_,-'-'   `-=_,-'-'   `-=_
    
EOF
        echo "$reset"
        # Set the window title, otherwise the title often reads as gibberish.
        echo -e "\033]; You're on your local MacBook \007"

```


**.vimrc**

```vim
set wrapmargin=8 shiftwidth=4 nohlsearch nowrap
au Filetype * set formatoptions=cql
set tags=~/kent/src/tags
colorscheme oceandeep
set noet ci pi sts=0 sw=8 ts=8
set encoding=utf-8
```

## ssh-keys

If you log into a server all the time, you'll want to set up your ssh keys so it doesn't prompt you for your password. A typical way to do this:

1. On your laptop, run `$ ssh-keygen`
..* Generally, go with the default options. Hit enter at the prompts, leaving them blank.
2. Take the generated contents of `~/.ssh/rsa_id.pub` and paste the line into one line on `~/.ssh/authorized_keys` on the server(s) you want to ssh into.
..* If you run into trouble, be sure to check permissions of `authorized_keys` - it won't work if it's readable by others. Try `$ chmod 600 authorized_keys`.
