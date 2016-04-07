#!/bin/bash 
#set -vx
#set -x

set -e

DBSERVICE=MyDB
DISCOVERY=ServiceReg

abort()
{
    if [ "$?" = "0" ]
    then
	return
    else
      echo >&2 '
      ***************
      *** ABORTED ***
      ***************
      '
      echo "An error occurred on line $1. Exiting..." >&2
      exit 1
    fi
}

summary()
{
  echo_msg "Current Services in CF_SPACE"
  cf services
}

echo_msg()
{
  echo ""
  echo "************** ${1} **************"
}

build()
{
  echo_msg "Building application"
  ./gradlew build 
}

cf_service_delete()
{
  #Were we supplied an App name?
  if [ ! -z "${2}" ]
  then
    EXISTS=`cf services | grep ${1} | grep ${2} | wc -l | xargs`
    if [ $EXISTS -ne 0 ]
    then
      APP=`cf services | grep ${1} | grep ${2} | xargs | cut -d" " -f4`
      cf unbind-service ${APP} ${1}
    fi
  fi

  #Delete the Service Instance
  EXISTS=`cf services | grep ${1} | wc -l | xargs`
  if [ $EXISTS -ne 0 ]
  then
    cf delete-service -f ${1}
  fi
}

clean_db()
{
  cf_service_delete $DBSERVICE $APPNAME
}

clean_eureka()
{
  cf_service_delete $DISCOVERY $APPNAME
}

create_service()
{
  service_created=0
  EXISTS=`cf services | grep ${1} | wc -l | xargs`
  if [ $EXISTS -eq 0 ]
  then
    cf create-service ${1} ${2} ${3}
    service_created=1
  fi
}

create_services()
{
  #Create Services
  echo_msg "Making initial (temporary) push to PCF"
  create_service p-mysql 100mb-dev $DBSERVICE
  create_service p-service-registry standard $DISCOVERY
  if [ $service_created -eq 1 ]
  then
    # Sleep for service registry
    max=12
    for ((i=1; i<=$max; ++i )) ; do
      echo "Pausing to allow Service Discovery to Initialise.....$i/$max"
      sleep 5
    done
  fi
}

check_cli_installed()
{
  #Is the CF CLI installed?
  echo_msg "Targeting the following CF Environment, org and space"
  cf target
  if [ $? -ne 0 ]
  then
    echo_msg "!!!!!! ERROR: You either don't have the CF CLI installed or you are not connected to an Org or Space !!!!!!"
    exit $?
  fi
}

check_not_running_on_PWS()
{
# Work out the CF_TARGET
  CF_TARGET=`cf target | grep "API" | cut -d" " -f5| xargs`
  # Disable PWS until we write the small script to check the name of the java buildpack
  PWS=`echo $CF_TARGET | grep "run.pivotal.io" | wc -l`
  if [ $PWS -ne 0 ]
  then
    echo_msg "This won't run on PWS, please use another environment"
    exit 1
  fi
}

trap 'abort $LINENO' 0
SECONDS=0

echo_msg "Welcome"
echo "This is a utility to script to setup services required by cities"
sleep 2

# Do actual work
check_not_running_on_PWS
check_cli_installed
summary
create_services
summary

#trap : 0

echo_msg "Script Complete in $SECONDS seconds."
