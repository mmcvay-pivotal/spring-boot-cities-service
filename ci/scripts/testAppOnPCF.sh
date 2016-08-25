#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

searchForCity()
{
  echo $URL
  running=`curl -s $URL | grep "Aldermoor"`
  exitIfNull $running
}

main()
{
  cf_login
  summaryOfApps
  checkSpringBootAppOnPCF $APPNAME
  searchForCity
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`

main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
