#!/bin/bash

# iOS_simulator.sh v1.0
# ARW 1/12/2019
# Installs a chosen iOS simulator

app=$(osascript <<EOF
set variableName to do shell script "/usr/local/lib/ruby/gems/2.6.0/bin/xcversion simulators | grep 'iOS.*not' | sort -u"
set testArray to paragraphs of the variableName
set selectedApp to {choose from list testArray}
return selectedApp
EOF
)

sim=$(echo ${app} | sed 's#\ S.*$##')

/usr/local/lib/ruby/gems/2.6.0/bin/xcversion simulators --install="${sim}"

/usr/local/bin/terminal-notifier -sound default -title "iOS installer" \
				 -contentImage /Library/Assets/logo-light.png \
				 -message "iOS simulator install complete"
