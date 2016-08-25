#!/bin/sh
. $APPNAME2/ci/scripts/common.sh

main()
{
  echo_msg "Starting build for ${APPNAME2}"
  cd $APPNAME2
  ./gradlew build
  cp build/libs/*.jar ../build
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
export TERM=${TERM:-dumb}
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
