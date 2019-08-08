#!/usr/bin/env bash

# Exit if any command fails.
set -o pipefail
trap 'exit' ERR

# Include helper library
. ./tools/utils.sh

VERSION="$1"
BRANCH="$2"

PACKAGE_NAME=$(get_default_package_name)
PACKAGE_VERSION=$(get_package_version "$PACKAGE_NAME" "$VERSION")

if [ ! -z "$PACKAGE_VERSION" ]; then
	echo "Promoting $PACKAGE_VERSION to released" >&2

	# Promote the package version to released
	RELEASE=$(sfdx force:package:version:promote -p "$PACKAGE_VERSION" --json --noprompt)
	STATUS="$(echo $RELEASE | jq '.status')"

	echo "$RELEASE" >&2

	if [ -z "$STATUS" ] || [ "$STATUS" -gt 0 ]; then
		exit 1
	fi

	echo "{ \"name\": \"$PACKAGE_NAME\", \"url\": \"https://login.salesforce.com/packaging/installPackage.apexp?p0=$PACKAGE_VERSION\" }"
fi
