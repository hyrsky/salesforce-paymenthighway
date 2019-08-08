#!/usr/bin/env bash

# Exit if any command fails.
set -o pipefail
trap 'exit' ERR

# Include helper library
. ./tools/utils.sh

VERSION="$1"
BRANCH="$2"

PACKAGE_NAME=$(get_default_package_name)
PACKAGE_URL=$(get_package_url "$PACKAGE_NAME" "$VERSION")

if [ ! -z "$PACKAGE_NAME" ] && [ ! -z "$PACKAGE_URL" ]; then
	echo "### Install url:"
	# Disable github autolinking: https://gist.github.com/alexpeattie/4729247.
	echo " * $PACKAGE_NAME<span>@</span>$VERSION.LATEST"
	echo "   $PACKAGE_URL"
fi
