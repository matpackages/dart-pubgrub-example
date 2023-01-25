Install packages:

    dart pub get

Run:

    dart run main.dart

```
git clone https://github.com/dart-lang/pub.git

mkdir -p temp/myapp
mkdir -p temp/config
mkdir -p temp/cache

WD=$(pwd)

dart pub get

dart run main.dart

export CI=false
export _PUB_TESTING=true
export _PUB_TEST_CONFIG_DIR=$WD/temp/config
export PUB_CACHE=$WD/temp/cache
export PUB_ENVIRONMENT="test-environment"
export _PUB_TEST_SDK_VERSION="3.1.2+3"
export PUB_HOSTED_URL="http://localhost:50356"

cd $WD/temp/myapp
dart run --enable-asserts $WD/pub/bin/pub.dart get

or 
dart run $WD/pub/bin/pub.dart get

# clean
rm pubspec.lock
rm -Rf ../cache/*
rm -Rf ../config/*
```