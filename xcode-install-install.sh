#!/bin/bash

# xcode-install-install_1.0.sh
# (as distinct from xcode_install :) )
# install the tool we use to install iOS simulators
#
# You need to install the 'rubyzip' package before this script runs
#
# v1.0 2019-11-29 Tony Williams (ARW)

consoleuser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; print(username);')"

/usr/local/bin/terminal-notifier -sound default -title "xcode-install" \
                 -contentImage /Library/Assets/logo-light.png \
                 -message "Installing Ruby 2.6.n"
sudo -u ${consoleuser} /usr/local/bin/brew install ruby
# turn off SSL verify for gem (proxy problem)
# gem will still complain at the top of the request but will do the install
sudo -u ${consoleuser} echo ":ssl_verify_mode: 0" >> /Users/${consoleuser}/.gemrc
/usr/local/bin/terminal-notifier -sound default -title "xcode-install" \
                 -contentImage /Library/Assets/logo-light.png \
                 -message "Installing rubyzip"
# for some reason we can't download rubyzip from behind our proxy so install it using our package
# then delete the package :)
/usr/local/opt/ruby/bin/gem install /Users/Shared/rubyzip-1.3.0.gem
rm /Users/Shared/rubyzip-1.3.0.gem
# now (finally) install our tool
/usr/local/bin/terminal-notifier -sound default -title "xcode-install" \
                 -contentImage /Library/Assets/logo-light.png \
                 -message "Installing xcode-install"
/usr/local/opt/ruby/bin/gem install xcode-install
