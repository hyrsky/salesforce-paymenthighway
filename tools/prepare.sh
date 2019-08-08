#!/usr/bin/env bash

# Exit if any command fails.
set -o pipefail
trap 'exit' ERR

# Include helper library
. ./tools/utils.sh

VERSION="$1"
BRANCH="$2"

PACKAGE_NAME=$(get_default_package_name)

# If found package name with current scope.
if [ ! -z "$PACKAGE_NAME" ]; then
	echo "Releasing $PACKAGE_NAME@$VERSION.NEXT"

	# Create new package version.
	PACKAGE=$(sfdx force:package:version:create -p "$PACKAGE_NAME" --installationkeybypass -w 20 -n "$VERSION.NEXT" -t "v$VERSION" -b "$BRANCH" --json)
	STATUS="$(echo $PACKAGE | jq '.status')"

	echo "$PACKAGE"

	if [ -z "$STATUS" ] || [ "$STATUS" -gt 0 ]; then
		exit 1
	fi

	# 04t... id of package version.
	PACKAGE_VERSION="$(echo $PACKAGE | jq -r '.result.SubscriberPackageVersionId')"
fi
