#!/bin/bash

# java-select.sh v1.0
# ARW 24/9/2019
# selects a java version

app=$(osascript <<EOF
set variableName to do shell script "cd /Library/Java/JavaVirtualMachines ; ls -d *"
set testArray to paragraphs of the variableName
set selectedApp to {choose from list testArray}
return selectedApp
EOF
)

cd /Library/Java/JavaVirtualMachines

for jvm in * ; do
	mv ${jvm}/Contents/Info.plist ${jvm}/Contents/Info.plist.disabled
done

mv ${app}/Contents/Info.plist.disabled ${app}/Contents/Info.plist
