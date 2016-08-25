#!/bin/sh 
set -e
. $APPNAME2/ci/scripts/common.sh

main()
{
  echo "App is: $APPNAME2"
  cf_login 
  cf services
  EXISTS=`cf services | grep ${SERVICE_NAME} | wc -l | xargs`
  if [ $EXISTS -eq 0 ]
  then
    PLAN=`cf marketplace -s p-mysql | grep MB | head -n 1 | cut -d ' ' -f1 | xargs`
    if [ -z $PLAN ]
    then
      PLAN=`cf marketplace -s p-mysql | grep MySQL | head -n 1 | cut -d ' ' -f1 | xargs`
    fi
    cf create-service p-mysql $PLAN ${SERVICE_NAME}
  fi
  cf services
  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
