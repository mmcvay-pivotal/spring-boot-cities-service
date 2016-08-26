#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

addVersionEnv()
{
  cf set-env $APPNAME VERSION $VERSION
}

newRoute()
{
  DOMAIN=`cf domains | grep shared | head -n 1 | cut -d" " -f1`
  VERSION=`echo $VERSION | sed -e 's/\./_/g'`
  echo "$APPNAME $DOMAIN -n $APPNAME-$VERSION"
  cf map-route $APPNAME $DOMAIN -n $APPNAME-$VERSION
}

main()
{
  cf_login

  summaryOfApps
  createVarsBasedOnVersion
  addVersionEnv
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
