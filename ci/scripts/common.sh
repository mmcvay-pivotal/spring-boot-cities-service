#!/bin/sh 
set -e
APPNAME=cities-ui

abort()
{
    echo >&2 '
    ***************
    *** ABORTED ***
    ***************
    '
    echo "An error occurred. Exiting..." >&2
    exit 1
}

echo_msg()
{
  echo ""
  echo "************** ${1} **************"
}

cf_login()
{
  cf --version
  cf login -a $api -u $username -p $password -o $organization -s $space $ssl
}

exitIfNull()
{
  if [ -z "${1}" ]
  then
    exit 1
  fi
}
