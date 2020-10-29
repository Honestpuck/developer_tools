#!/bin/bash

# xcode-select.sh v1.0
# ARW 24/9/2019
# runs xcode-select on a chosen Xcode version

app=$(osascript <<EOF
set variableName to do shell script "cd /Applications ; ls -d Xcode*"
set testArray to paragraphs of the variableName
set selectedApp to {choose from list testArray}
return selectedApp
EOF
)

xcode-select --switch  "/Applications/${app}"
