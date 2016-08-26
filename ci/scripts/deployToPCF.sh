#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

createNewNameBasedOnVersion()
{
  VERSION=`cat resource-version/number`
  echo $VERSION

  cd $APPNAME
  CF_APPNAME=$APPNAME-$username-$VERSION
  echo $CF_APPNAME
}

push()
{
  echo_msg "Pushing new Microservice"
  ls ../build/
  BPACK=`cf buildpacks | grep java | grep true | head -n 1 | cut -d ' ' -f1 | xargs`
  echo "cf push $CF_APPNAME -f manifest.yml -p ../build/${APPNAME}.jar -b ${BPACK} -n ${CF_APPNAME}"
  cf push $CF_APPNAME -f manifest.yml -p ../build/${APPNAME}.jar -b ${BPACK} -n ${CF_APPNAME}

  echo "Pushing Live Route"
  DOMAIN=`cf domains | grep shared | head -n 1 | cut -d" " -f1`
  echo "$CF_APPNAME $DOMAIN -n $CF_APPNAME-$username"
  cf map-route $CF_APPNAME $DOMAIN -n $CF_APPNAME-$username
}

main()
{
  cf_login
  summaryOfApps

  createNewNameBasedOnVersion
  push

  summaryOfApps
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
