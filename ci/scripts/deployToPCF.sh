#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

main()
{
  cf_login
  summaryOfApps
  VERSION=`cat resource-version/number`
  echo $VERSION

  cd $APPNAME
  ## Variables used during Jenkins Build Process
  APPNAME=$APPNAME-$VERSION

  echo_msg "Pushing new Microservice"
  ls ../build/
  BPACK=`cf buildpacks | grep java | grep true | head -n 1 | cut -d ' ' -f1 | xargs`
  cf push $APPNAME -p ../build/${APPNAME}.jar -f manifest.yml -b ${BPACK}

  summaryOfApps
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
