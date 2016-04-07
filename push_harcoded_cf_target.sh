#!/bin/bash 
#set -vx
#set -x

set -e

APPNAME=cities-service
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
  echo_msg "Current Apps & Services in CF_SPACE"
  cf apps
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

delete_previous_apps()
{
  APPS=`cf apps | grep $APPNAME | cut -d" " -f1`
  for app in ${APPS[@]}
  do
    cf delete -f -r $app
  done
  echo_msg "Removing Orphaned Routes"
  cf delete-orphaned-routes -f
}

get_old_route()
{
  echo_msg "Detecting Original Route"
  # Fetch current apps and
  # 1) Filter out ones with our app name
  # 2) Removing trailing spaces
  # 3) replace the space character in the separator between route names
  # 4) Grab the last part of string (i.e. just the routes of the apps)
  # 5) Split multiple routes into separate lines
  # 6) Remove the domain
  OLD_ROUTES=`cf apps | grep $SRC_APP_NAME | sed -e 's/[[:space:]]*$//' | sed "s/, /,/" | rev | cut -d" " -f1 | rev | tr , '\n' | cut -d "." -f1`
  for A_ROUTE in ${OLD_ROUTES[@]}
  do
    #if [[ $A_ROUTE != *$APPNAME* ]]; then
     #   continue
    #fi
    A_ROUTE=`echo $A_ROUTE | xargs`
    if ! [[ $A_ROUTE =~ [0-9] ]]; then
        OLD_ROUTE=$A_ROUTE
        break
      else
        OLD_ROUTE=""
    fi
  done
  echo "OLD ROUTE IS $OLD_ROUTE"
  if [[ ! "$OLD-ROUTE" || "$OLD_ROUTE" == "" ]]; then
    echo "Could not determine previous route!!"
    exit 1
  fi
}

map_new_routes()
{
  # Add non-unique route for future blue/green deployments
  if [ "$PROMOTE" != "true" ]
  then
    RANDOM_ROUTE=`cf app $APPNAME | grep urls | cut -d":" -f2 | sed "s/-$DATE//" |  cut -d"." -f1 | xargs`
    cf map-route $APPNAME $DOMAIN -n $RANDOM_ROUTE
    return 0
  fi

  # Alternately for app promotion
  cf map-route $APPNAME $DOMAIN -n $OLD_ROUTE
  echo_msg "Route mapped to old and new version of Application"
  cf apps

  echo "Temp sleep in script for demo purposes only........."
  sleep 10

  #Remove the old version
  echo_msg "Removing previous versions"
  APPS_TO_DELETE=`cf apps | grep $SRC_APP_NAME | cut -d" " -f1 | grep -v $APPNAME`
  for APP_TO_DELETE in ${APPS_TO_DELETE[@]}
  do
    cf delete -f $APP_TO_DELETE
  done
  echo_msg "Removing orphaned routes"
  cf delete-orphaned-routes -f
  cf apps
}

push()
{
  # Push App
  echo "Pushing $APPNAME"
  DOMAIN=`cf domains | grep shared | head -n 1 | cut -d" " -f1`

  # Is this an app Promotion?
  if [ "$PROMOTE" == "true" ]
  then
    get_old_route
    cf push $APPNAME -b java_buildpack_offline -f manifest_quick.yml
  else
    cf push $APPNAME -b java_buildpack_offline --random-route -f manifest_quick.yml
  fi

  map_new_routes
}

check_not_on()
{
  if [ "$SKIP_BUILD" != "true" ]
  then
    build
  fi

  # Work out the CF_TARGET
  CF_TARGET=`cf target | grep "API" | cut -d" " -f5| xargs`
  # Disable PWS until we write the small script to check the name of the java buildpack
  PWS=`echo $CF_TARGET | grep "run.pivotal.io" | wc -l`
  if [ $PWS -ne 0 ]
  then
    echo_msg "This won't run on PWS, please use another environment"
    exit 1
  fi

  process_reset_args

  if [ "$SKIP_PUSH" != "true" ]
  then
    push
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

trap 'abort $LINENO' 0
SECONDS=0

echo_msg "Welcome"
echo "This is a utility to script to push or promote the cities app"
sleep 2

# Do actual work
check_cli_installed
summary
build
push
summary

#trap : 0

echo_msg "Deployment Complete in $SECONDS seconds."
