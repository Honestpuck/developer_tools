#!/bin/bash

# xcodeInstall.sh v2.3
# hacked this out of the old post install script. It assumes you have downloaded and unpacked Xcode in your Downloads folder.
#
#
# 23 Sept 2019 - Tony Williams
# clean up script from old Casper
# v2.1 Added tool install
# v2.2 Bugs? Never bugs!
# v2.3 4/11/2019 ARW Added '-allowUntrusted' to fix problem with tighter macOS security

# Install for Xcode - based on Hunty's post install
# but not hardcoding Xcode and run postinstall (xcode installed to default - coz i don't wanna repkg :))
#
# it will check for an Xcode app in the default location
# if found it will rename it to Xcode_${version}.app
# and then:
# - accept license
# - add current user to _developer
# - enable developer mode
# - install all embedded pkgs

consoleuser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"

xcode="/Users/${consoleuser}/Downloads/Xcode.app"
xcode_default_path="/Applications/Xcode.app"

# here is the hack
if [ -d "${xcode}" ]
then
	/usr/local/bin/terminal-notifier -sound default -title "Xcode" \
		-contentImage /Library/Assets/logo-light.png \
		-message "Moving Xcode"
	mv "${xcode}" /Applications
else
    echo "error: couldn't find Xcode at ${xcode}"
	/usr/local/bin/terminal-notifier -sound default -title "Xcode" \
		-contentImage /Library/Assets/logo-light.png \
		-message "Xcode missing at ${xcode}"
    exit 1
fi

if [ -d "${xcode_default_path}" ]
then
    plist="${xcode_default_path}/Contents/Info.plist"
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ${plist} )
   if [ -z "${version}" ]
   then
       echo "error: couldn't get Xcode version"
	   /usr/local/bin/terminal-notifier -sound default -title "Xcode" \
		   -contentImage /Library/Assets/logo-light.png \
		   -message "Couldn't get Xcode version"
       exit 1
   fi
   # we have a version - check if there is already one present
   xcode_new_path="/Applications/Xcode_${version}.app"
   if [ -d "${xcode_new_path}" ]
   then
       echo "error: xcode already exists: ${xcode_new_path}"
	   /usr/local/bin/terminal-notifier -sound default -title "Xcode" \
		   -contentImage /Library/Assets/logo-light.png \
		   -message "Xcode already exists: ${xcode_new_path}"
       exit 1
   else
       # rename app
       mv "${xcode_default_path}" "${xcode_new_path}"
       fi
else
    echo "error: couldn't find Xcode at ${xcode_default_path}"
	/usr/local/bin/terminal-notifier -sound default -title "Xcode" \
		-contentImage /Library/Assets/logo-light.png \
		-message "Couldn't find Xcode at ${xcode_default_path}"
    exit 1
fi

# Make user member of the _developer group
/usr/sbin/dseditgroup -o edit -a ${consoleuser} -t user _developer

# Enable developer mode
/usr/sbin/DevToolsSecurity -enable

# Accept Xcode license
"${xcode_new_path}/Contents/Developer/usr/bin/xcodebuild" -license accept

# Install embedded packages
echo "installing embedded packages ..."
/usr/local/bin/terminal-notifier -sound default -title "Xcode" \
	-contentImage /Library/Assets/logo-light.png \
	-message "Installing embedded packages"

for pkg in "${xcode_new_path}/Contents/Resources/Packages/"*.pkg
do
    echo "installing: $pkg ..."
    /usr/sbin/installer -allowUntrusted -pkg "$pkg" -target /
done

echo "done!"
exit
