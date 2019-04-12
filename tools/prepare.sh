#!/usr/bin/env bash

VERSION="$1"
BRANCH="$2"
COMMITS="$3"
TIME="$4"

sfdx force:package:version:create -d force-app --installationkeybypass -w 20 -a "$VERSION" -t "$VERSION" -b "$BRANCH"