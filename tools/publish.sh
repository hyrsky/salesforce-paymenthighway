#!/usr/bin/env bash

PACKAGE_NAME="$(jq -r '.packageDirectories[] | select(.default==true) | .package' sfdx-project.json)"
VERSION="$1"
BRANCH="$2"
COMMITS="$3"
TIME="$4"

SFDX_CLI_EXEC=sfdx

# Defining Salesforce CLI exec, depending if it's CI or local dev machine
if [ $CI ]; then
    # echo "Script is running on CI"
    SFDX_CLI_EXEC="sfdx"
fi

PACKAGE=$($SFDX_CLI_EXEC force:package:version:create -p "$PACKAGE_NAME" --installationkeybypass -w 20 -n "$VERSION.NEXT" -a "$VERSION-$BRANCH" -t "v$VERSION" -b "$BRANCH" --json)
STATUS="$(echo $PACKAGE | jq '.status')"

if [ -z "$STATUS" ] || [ "$STATUS" -gt 0 ]; then
    echo "$PACKAGE"
    exit 1
fi

PACKAGE_VERSION="$(echo $PACKAGE | jq -r '.result.SubscriberPackageVersionId')"

# Only promote master branch.
RELEASE=$($SFDX_CLI_EXEC force:package:version:promote -p "$PACKAGE_VERSION" --json --noprompt)
STATUS="$(echo $PACKAGE | jq '.status')"

if [ -z "$STATUS" ] || [ "$STATUS" -gt 0 ]; then
    echo "$STATUS"
    exit 1
fi

RELEASE_ID="$(echo $RELEASE | jq -r '.result.id')"

echo "{ \"name\": \"$PACKAGE_NAME\", \"url\": \"https://login.salesforce.com/packaging/installPackage.apexp?p0=$RELEASE_ID\" }"