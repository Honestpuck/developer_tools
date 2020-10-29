#!/bin/bash

if [[ -e /Applications/terminal-notifier.app ]] ; then
	app='/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier'
fi

if [[ -e /usr/local/bin/terminal-notifier ]] ; then
	app='/usr/local/bin/terminal-notifier'
fi

if [[ -z $app ]] ; then
	exit 1
fi

title="${5:-Gateway}"
$app -sound default -title "${title}" \
-contentImage /Library/Assets/logo-light.png -message "${4}"
