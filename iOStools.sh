#!/bin/bash

consoleuser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; print(username);')"

echo "consoleuser ${consoleuser}"

# Make user member of the _developer group
/usr/sbin/dseditgroup -o edit -a ${consoleuser} -t user _developer

echo "installing tools"
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing Carthage"
sudo -u ${consoleuser} /usr/local/bin/brew install carthage
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing swiftlint"
sudo -u ${consoleuser} /usr/local/bin/brew install swiftlint
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing fastlane"
sudo -u ${consoleuser} /usr/local/bin/brew cask install fastlane
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing Python 3"
sudo -u ${consoleuser} /usr/local/bin/brew install python
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing lizard"
sudo -u ${consoleuser} /usr/local/bin/pip3 install lizard --user
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Installing sinatra"
gem install thin ; gem install sinatra
/usr/local/bin/terminal-notifier -sound default -title "iOS Tools" -contentImage /Library/Assets/logo-light.png -message "Finishing up"

cat <<'EOF' | tee /usr/local/bin/lizard
#!/usr/bin/env bash
 
/usr/local/bin/python3 -m lizard "$@"
EOF

chmod a+x /usr/local/bin/lizard

cat <<'EOF' | tee -a /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc

# Python 3 configuration
alias python="python3"
alias pip="pip3"

# Fastlane configuration
export PATH="$HOME/.fastlane/bin:$PATH"

# Ruby configuration
export PATH="$HOME/.gem/ruby/2.3.0/bin:$PATH"
SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk/
export SDKROOT

EOF

chown ${consoleuser} /usr/local/bin/lizard /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
