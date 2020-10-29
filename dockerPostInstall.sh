#!/bin/bash
#
# docker postinstall script
#
# loads network privleged helper and adds entry to host file

launchdaemon="/Library/LaunchDaemons/com.docker.vmnetd.plist"
docker_hosts_entry="# Added by Docker Desktop
# To allow the same kube context to work on the host and the container:
127.0.0.1 kubernetes.docker.internal
# End of section
"

launchctl load "${launchdaemon}"

check_for_hosts_entry=$(cat /etc/hosts | grep "$(echo "${docker_hosts_entry}" | head -n1)")

if [ -z "${check_for_hosts_entry}" ] ; then
    echo "${docker_hosts_entry}" >> /etc/hosts
fi

exit
