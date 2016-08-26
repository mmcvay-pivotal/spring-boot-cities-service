#!/bin/sh
. $APPNAME/ci/scripts/common.sh

## Only necessary if demoing on shared env with many people pushing the same app
## Using random-route: true screws up autopilot

main()
{
  cd $APPNAME
  more manifest.yml
  cat ../../manifest.yml | head -n 5 >> manifest.tmp
  echo "  host: $APPNAME-$username" >> manifest.tmp
  cat ../../manifest.yml | tail -n 6
  mv manifest.tmp manifest.yml
  more manifest.yml
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
export TERM=${TERM:-dumb}
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
