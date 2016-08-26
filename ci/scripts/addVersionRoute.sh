#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

newRoute()
{
  DOMAIN=`cf domains | grep shared | head -n 1 | cut -d" " -f1`
  echo "$APPNAME $DOMAIN -n $APPNAME-$username"
  cf map-route $APPNAME $DOMAIN -n $APPNAME-$VERSION
}

main()
{
  cf_login

  summaryOfApps
  createVarsBasedOnVersion
  newRoute
  summaryOfApps

  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
