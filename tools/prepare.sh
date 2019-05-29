#!/usr/bin/env bash

VERSION="$1"
BRANCH="$2"
COMMITS="$3"
TIME="$4"

# tmp=$(mktemp)
# Replace version number in sfdx-project.json.
# jq '.packageDirectories[].versionNumber = "${VERSION}"' sfdx-project.json >> "$tmp" && mv "$tmp" sfdx-project.json
