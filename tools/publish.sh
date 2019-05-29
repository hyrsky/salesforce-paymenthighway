#!/usr/bin/env bash

PACKAGE_NAME="$1"
VERSION="$2"
BRANCH="$3"
COMMITS="$4"
TIME="$5"

SFDX_CLI_EXEC=sfdx

# Defining Salesforce CLI exec, depending if it's CI or local dev machine
if [ $CI ]; then
    echo "Script is running on CI"
    # SFDX_CLI_EXEC=node_modules/sfdx-cli/bin/run
fi

PACKAGE=$($SFDX_CLI_EXEC force:package:version:create -p "$PACKAGE_NAME" --installationkeybypass -w 20 -a "$VERSION" -t "$VERSION" -b "$BRANCH" --json)
STATUS="$(echo $PACKAGE | jq '.status')"

if [ -z $STATUS ]; then
    exit 1
elif [ $STATUS -gt 0 ]; then
    echo $PACKAGE
    exit 1
fi

echo "$VERSION"
echo "$PACKAGE"

PACKAGE_VERSION = "$(echo $PACKAGE | jq -r '.result.SubscriberPackageVersionId')"

# Only promote master branch.
sfdx force:package:version:promote -p "$PACKAGE_VERSION" --json --noprompt 