#!/bin/bash
#
# javaRootCerts
#
# Copies or deletes Java root certificates  from $5 to $6
#
# Lachlan Stewart
#
# ARW 3/12/2019 Clean up
#

usage()
{
  echo "Usage: $(basename ${0}) '' '' '' --add [path_to_java] [path_to_certs]"
  echo "       $(basename ${0}) '' '' '' --remove [path_to_java] [path_to_certs]"
  exit 1
}

if [ "${1}" == "" ]
then
  usage
fi

mode="${4}"
cert_file_ext="crt"
keytool_bin="bin/keytool"
cacerts_keystore="lib/security/cacerts"
keystore_password="password"

#
# set defaults
#

if [ "${5}" == "" ] ; then
  java_dir="/Library/Java"
else
  java_dir="${5}"
fi

if [ "${6}" == "" ] ; then
  cert_dir="$(dirname ${0})"
else
  cert_dir="${6}"
fi

# handle destination not existing. We may not have Android Studio.
if [[ ! -e ${java_dir} ]] ; then
	exit 0
fi

#
# do the job
#

# find jre dirs under java_dir
jre_dirs=( $(find "${java_dir}" -type d -name 'jre') )
echo "found JRE: ${jre_dirs}"

for jre_dir in "${jre_dirs[@]}" ; do
  echo "processing keystore: ${jre_dir}/${cacerts_keystore}"
  # loop over list of certificate files and add them
  for cert_file in ${cert_dir}/*.${cert_file_ext} ; do
  	cert_name="$(basename -- ${cert_file} .${cert_file_ext})"
  	cert_found=$("${jre_dir}/${keytool_bin}" -list -v -keystore "${jre_dir}/${cacerts_keystore}" -storepass ${keystore_password} -noprompt | grep -w "${cert_name}")
  	# Check if the certificate is already in the keystore
  	if [ -n "${cert_found}" ] ; then
  		echo "${cert_name}: remove existing.."
      "${jre_dir}/${keytool_bin}" -delete -alias ${cert_name} -keystore "${jre_dir}/${cacerts_keystore}" -storepass ${keystore_password} -noprompt
  	fi
    if [ "${mode}" == "--add" ] ; then
  		echo "${cert_name}: installing.."
    	"${jre_dir}/${keytool_bin}" -import -trustcacerts -file ${cert_file} -keystore "${jre_dir}/${cacerts_keystore}" -alias ${cert_name} -storepass ${keystore_password} -noprompt
    fi
  done
done
echo "Done!"
