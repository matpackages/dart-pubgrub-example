#!/bin/bash

PORT=$1

rm -Rf temp/config
rm -Rf temp/cache
rm -f temp/myapp/pubspec.lock

WD=$(pwd)

export CI=false
export _PUB_TESTING=true
export _PUB_TEST_CONFIG_DIR=$WD/temp/config
export PUB_CACHE=$WD/temp/cache
export PUB_ENVIRONMENT="test-environment"
export _PUB_TEST_SDK_VERSION="3.1.2+3"
export PUB_HOSTED_URL="http://localhost:$PORT"

cd $WD/temp/myapp
dart run $WD/pub/bin/pub.dart get
# dart run --enable-asserts $WD/pub/bin/pub.dart get
