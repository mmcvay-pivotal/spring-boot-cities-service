#!/bin/sh 
. $APPNAME2/ci/scripts/common.sh

searchForCity()
{
  running=`curl -s $URL | grep "Aldermoor"`
  exitIfNull $running
}

main()
{
  cf_login
  checkSpringBootAppOnPCF $APPNAME2
  searchForCity
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`

main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
