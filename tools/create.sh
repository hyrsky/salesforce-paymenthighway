#!/usr/bin/env bash

PACKAGE_NAME="$1"
DESCRIPTION="$2"

sfdx force:package:create --name "$PACKAGE_NAME" --description "$DESCRIPTION" --packagetype Unlocked --path force-app --nonamespace