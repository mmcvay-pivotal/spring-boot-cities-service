#!/bin/sh 
. $APPNAME/ci/scripts/common.sh

searchForCity()
{
  running=`curl -s $URL/cities/search/name?q=Aldermoor | grep "SU3915"`
  exitIfNull $running
}

main()
{
  cf_login

  summaryOfApps
  ls ../deployOutputs/outputs.list
  cat ../deployOutputs/outputs.list
  CF_APPNAME = cat ../deployOutputs/outputs.list | grep CF_APPNAME | cut -d "=" -f2
  echo $CF_APPNAME

  createVarsBasedOnVersion
  checkSpringBootAppOnPCF $CF_APPNAME
  searchForCity

  cf logout
}

trap 'abort $LINENO' 0
SECONDS=0
SCRIPTNAME=`basename "$0"`
main
printf "\nExecuted $SCRIPTNAME in $SECONDS seconds.\n"
trap : 0
