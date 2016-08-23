#!/bin/sh

export TERM=${TERM:-dumb}
echo "****** Starting"
cd cities-service
./gradlew build
mkdir ../build/libs
cp build/libs/*.jar ../build/libs
echo "****** Finished"
