#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

searchForCity()
{
  echo " Searching for Aldemoor ... at $URL"
  curl -s $URL
  curl -s $URL | grep "Aldermoor"
  running=`curl -s $URL | grep "Aldermoor"`
  echo $running
  exitIfNull $running
}

main()
{
  cf_login
  summaryOfApps
  checkSpringBootAppOnPCF $APPNAME
  searchForCity
  echo "logging out"
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
