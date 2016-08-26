#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

push()
{
  echo_msg "Pushing new Microservice"
  cd $APPNAME

  BPACK=`cf buildpacks | grep java | grep true | head -n 1 | cut -d ' ' -f1 | xargs`
  echo "cf push $CF_APPNAME -f manifest.yml -p ../build/${JARNAME} -b ${BPACK} -n ${CF_APPNAME}"
  cf push $CF_APPNAME -f manifest.yml -p ../build/${JARNAME} -b ${BPACK} -n ${CF_APPNAME}

  echo "Pushing Live Route"
  DOMAIN=`cf domains | grep shared | head -n 1 | cut -d" " -f1`
  echo "$CF_APPNAME $DOMAIN -n $APPNAME-$username"
  cf map-route $CF_APPNAME $DOMAIN -n $APPNAME-$username
}

main()
{
  cf_login
  summaryOfApps

  createVarsBasedOnVersion
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
