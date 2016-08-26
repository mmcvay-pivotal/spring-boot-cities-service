#!/bin/sh
. $APPNAME/ci/scripts/common.sh

main()
{
  cd $APPNAME
  more manifest.yml
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
export TERM=${TERM:-dumb}
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
