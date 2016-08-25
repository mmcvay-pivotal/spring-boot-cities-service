#!/bin/sh
. $APPNAME/ci/scripts/common.sh

main()
{
  echo_msg "Starting assemble for ${APPNAME}"
  VERSION=`cat resource-version/number`
  cd $APPNAME
  ./gradlew assemble -P $VERSION
  cp build/libs/*.jar ../build
  ls ../build
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
export TERM=${TERM:-dumb}
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
