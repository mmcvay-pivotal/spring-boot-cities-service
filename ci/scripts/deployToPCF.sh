#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

createNewNameBasedOnVersion()
{
  VERSION=`cat resource-version/number`
  echo $VERSION

  cd $APPNAME
  APPNAME=$APPNAME-$VERSION
}

push()
{
  echo_msg "Pushing new Microservice"
  ls ../build/
  BPACK=`cf buildpacks | grep java | grep true | head -n 1 | cut -d ' ' -f1 | xargs`
  cf push $APPNAME -p ../build/${APPNAME}.jar -f manifest.yml -b ${BPACK}
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
