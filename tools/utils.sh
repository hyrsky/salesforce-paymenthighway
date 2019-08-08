# Get default package name.
#
# Usage:
# 	get_package_name
get_default_package_name () {
	jq -r '.packageDirectories[] | select(.default == true) | .package' sfdx-project.json
}

# Query package install url with package name and version string
#
# Usage:
# 	get_package_url package-alias version
get_package_url() {
	local name="$1"
	local version="$2"

	sfdx force:package:version:list \
		-p "$name" \
		--createdlastdays 1 \
		--json \
		--concise \
		--orderby="CreatedDate DESC" \
			| jq -r 'first(.result[] | select(.Name == "'"$version"'")) | .InstallUrl'
}

# Query package version id with package name and version string
#
# Returns 04t... format package version.
#
# Usage:
# 	get_latest_package_version package-alias version
get_package_version () {
	local name="$1"
	local version="$2"

	sfdx force:package:version:list \
		-p "$name" \
		--createdlastdays 1 \
		--json \
		--concise \
		--orderby="CreatedDate DESC" \
			| jq -r 'first(.result[] | select(.Name == "'"$version"'")) | .SubscriberPackageVersionId'
}
