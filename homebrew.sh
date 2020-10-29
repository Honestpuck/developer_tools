#!/bin/bash

# Script to install Homebrew on a Mac.
# Author: richard at richard - purves dot com
# Version: 1.0 - 21st May 2017

# Heavily hacked by Tony Williams
# v2.0 - 19th Sept 2019
# v2.0.1 Fixed global cache error
# v2.0.2 Fixed brew location error
# v2.0.3 Added more directories to handle

# Set up variables and functions here
consoleuser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"

# are we in the right group
check_grp=$(groups ${consoleuser} | grep -c '_developer')
if [[ $check_grp != 1 ]]; then
    /usr/sbin/dseditgroup -o edit -a "${consoleuser}" -t user _developer
fi

# Logging stuff starts here
LOGFOLDER="/private/var/log/"
LOG="${LOGFOLDER}Homebrew.log"

if [ ! -d "$LOGFOLDER" ];
then
    mkdir $LOGFOLDER
fi

function logme()
{
# Check to see if function has been called correctly
    if [ -z "$1" ]
    then
        echo "$( date ) - logme function call error: no text passed to function! Please recheck code!"
        echo "$( date ) - logme function call error: no text passed to function! Please recheck code!" >> $LOG
        exit 1
    fi

# Log the passed details
    echo -e "$( date ) - $1" >> $LOG
    echo -e "$( date ) - $1"
}

# Check and start logging
logme "Homebrew Installation"

# Have the xcode command line tools been installed?
logme "Checking for Xcode Command Line Tools installation"
check=$( pkgutil --pkgs | grep -c "CLTools_Executables" )

if [[ "$check" != 1 ]];
then
    logme "Installing Xcode Command Tools"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    clt=$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)
    softwareupdate -i "$clt"
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

# Is homebrew already installed?
if [[ ! -e /usr/local/bin/brew ]];
then
    # Install Homebrew. This doesn't like being run as root so we must do this manually.
    logme "Installing Homebrew"

    mkdir -p /usr/local/Homebrew
    # Curl down the latest tarball and install to /usr/local
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /usr/local/Homebrew

    # Manually make all the appropriate directories and set permissions
    mkdir -p /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc
    mkdir -p /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share
    mkdir -p /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    mkdir -p /usr/local/share/doc /usr/local/share/man /usr/local/man/man1
    chown -R "${consoleuser}" /usr/local/*
    chmod g+rwx /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc
    chmod g+rwx /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share
    chmod g+rwx /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chmod g+rwx /usr/local/share/doc /usr/local/share/man /usr/local/man/man1
    chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
    chgrp _developer /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc
    chgrp _developer /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share
    chgrp _developer /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chgrp _developer /usr/local/share/doc /usr/local/share/man /usr/local/man/man1
    # Create a system wide cache folder  
    mkdir -p /Library/Caches/Homebrew
    chmod g+rwx /Library/Caches/Homebrew
    chown "${consoleuser}:_developer" /Library/Caches/Homebrew

    # put brew where we can find it
    ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew

    # Install the MD5 checker or the recipes will fail
    su -l "$consoleuser" -c "/usr/local/bin/brew install md5sha1sum"
    su -l "$consoleuser" -c "/usr/local/bin/brew install terminal-notifier"
    echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' | tee -a /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
	chown ${consoleuser} /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
fi

# Make sure everything is up to date
logme "Updating Homebrew"
chown -R "${consoleuser}" /usr/local/*
su -l "$consoleuser" -c "/usr/local/bin/brew update" 2>&1 | tee -a ${LOG}

# logme user that all is completed
logme "Installation complete"

exit 0
