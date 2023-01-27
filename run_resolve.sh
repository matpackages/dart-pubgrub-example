#!/bin/bash

PORT=$1

rm -Rf temp/cache

export _PUB_TEST_SDK_VERSION="3.1.2+3"
export PUB_HOSTED_URL="http://localhost:$PORT"

dart run resolve.dart
