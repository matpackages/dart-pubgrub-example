#!/bin/bash

function error_usage {
    echo "Usage: bash pub_semver.sh patch|restore"
    exit 1
}

if [[ $# != 1 ]]; then
    error_usage
fi

package='pub_semver'
version='2.1.3'

src="patch/$package-$version/"
pkg_root=~/".pub-cache/hosted/pub.dev/$package-$version"

result=$(dart pub deps | grep "$package ")

if [[ "$result|" == *"$package $version|"* ]]; then
    # echo "$package $version installed. continuing."
    echo -n
else
    echo "ERROR: $package $version is not installed."
    echo "The automatic patch only works for this version."
    echo "Aborting."
    exit 1
fi

echo $1

if [[ "$1" == "patch" ]]; then
    files="$src*"
    dst="$pkg_root/lib/src/"
    cp $files "$dst" || exit 1
elif [[ "$1" == "restore" ]]; then
    rm -rf "$pkg_root"
    dart pub get > /dev/null 2> /dev/null || exit 1
else
    error_usage
fi
