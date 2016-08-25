#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

checkAppIsDeployed()
{
  URL=`cf apps | grep $APPNAME | xargs | cut -d " " -f 6`
  exitIfNull $URL

  running=`curl -s $URL/health | grep '"status" : "UP"' `
  exitIfNull $running
}

searchForCity()
{
  running=`curl -s $URL | grep "Aldermoor"`
  exitIfNull $running
}

main()
{
  cf_login
  checkAppIsDeployed
  searchForCity
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`

main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
