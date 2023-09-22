#!/usr/bin/env bash

###
# Responsible for updating dependencies within this repo
##

set -e
trap cleanup HUP INT TERM EXIT QUIT ERR

cleanup()
{
	rm -f .update.tmp
	rm -f ../.update.tmp
	rm -f .update-dotnet.tmp
	rm -f src/.update-dotnet.tmp
	rm -f .changelog.tmp
	rm -f src/.changelog.tmp
}

red=$'\e[0;31m'
grn=$'\e[0;32m'
blu=$'\e[0;34m'
mag=$'\e[0;35m'
cyn=$'\e[0;36m'
end=$'\e[0m'

# CHANGELOG updated flag
CHANGELOG_UPDATED=false

####
# NPM Dependencies
####
echo -e "* Checking for ${blu}npm${end} dependency updates..."

if npm outdated ; then
	echo -e "${grn}[OK]${end} No npm updates required!"
else
	# Get the list of updates and confirm whether to conduct update - and catch the non-zero exit code
	npm outdated --json > .update.tmp ||
	read -p "Update npm packages? (${grn}y${end}/${red}n${end}) " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Identify the packages that have updates
		UPDATE_PACKAGES=$(jq 'to_entries | .[] | select(.value.current != .value.wanted) | "  - `" + .key + "` v" + .value.current + " => v" + .value.wanted' --raw-output < .update.tmp)

		# Check if there is any packages to update
		if [ -n "$UPDATE_PACKAGES" ]; then
			# Update
			printf "\n\n😎 Updating packages:\n%s%s%s\n" "${cyn}" "${UPDATE_PACKAGES}" "${end}"
			npm update

			# Update the package.json file to include the latest versions installed
			# See https://github.com/npm/cli/issues/708#issuecomment-810077954
			npm list --json | jq --slurpfile package package.json '
			def replaceVersion($replacements):
				with_entries(
					if .value | startswith("^")
					then
						.value = ("^" + $replacements[.key].version)
					else
						.
					end
				);
			.dependencies as $resolved
			| reduce ["dependencies", "devDependencies"][] as $deps (
				$package[0];
				if .[$deps] | type == "object"
				then
					.[$deps] |= replaceVersion($resolved)
				else
					.
				end
			)' > package.json~
			mv package.json~ package.json
			npm install

			# Write the CHANGELOG.md
			echo -e "- Update NPM dependencies" >> .changelog.tmp
			sed -i '/## Release-next/r .changelog.tmp' CHANGELOG.md

			# Indicate CHANGELOG been updated
			CHANGELOG_UPDATED=true
		fi

		# Identify major versions that will not be updated
		MAJOR_UPDATES=$(jq 'to_entries | .[] | select(.value.wanted != .value.latest) | "  - `" + .key + "` v" + .value.wanted + " => v" + .value.latest' --raw-output < .update.tmp)
		if [ -n "$MAJOR_UPDATES" ]; then
			printf "\n\n🤓 Packages with major updates that require updating manually:\n%s%s%s" "${mag}" "${MAJOR_UPDATES}" "${end}"
		fi
	fi
fi

####
# Go Dependencies
####
echo -e "\n\n* Checking for ${blu}Golang${end} updates..."
go list -u -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}} {{.Version}} -> {{.Update.Version}}{{end}}' -m all 2> /dev/null > .update.tmp
cat .update.tmp
if [ ! -s .update.tmp ] ; then
	echo -e "${grn}[OK]${end} Our Golang dependencies are up to date!"
else
	read -p "Update Golang packages? (${grn}y${end}/${red}n${end}) " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Update
		awk '{print $1}' < .update.tmp| xargs go get -u
		# Write the CHANGELOG.md
		echo -e "\n- Update Golang dependencies" > .changelog.tmp
		sed -i '/## Release-next/r .changelog.tmp' CHANGELOG.md
		# Indicate CHANGELOG been updated
		CHANGELOG_UPDATED=true
	fi
fi

####
# .NET Tool Dependencies
#
# Updates dotnet tools, this command updates the requires tools in the ./config/dotnet-tools.json
####
dotnet tool list | awk '{ print $1 }' | tail +3 | xargs -I % sh -c 'dotnet tool update %;'

####
# .NET Dependencies
####
echo -e "\n* Checking for ${blu}.NET${end} dependency updates..."
cd src
dotnet outdated -o .update-dotnet.tmp

if [ ! -f .update-dotnet.tmp ] ; then
	echo -e "${grn}[OK]${end} Our .NET dependencies are up to date!"
else
	# Identify the packages that have updates
	read -p "Update .NET packages? (${grn}y${end}/${red}n${end}) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Update
		dotnet outdated -u

		# Write the CHANGELOG.md
		echo -e "- Update .NET dependencies" >> .changelog.tmp
		sed -i '/## Release-next/r .changelog.tmp' ../CHANGELOG.md

		# Indicate CHANGELOG been updated
		CHANGELOG_UPDATED=true
	fi
fi
cd ..

# If updated add the Maintenance header
if $CHANGELOG_UPDATED; then
	echo -e "\n### 🛠️ Maintenance\n" > .changelog.tmp
	sed -i '/## Release-next/r .changelog.tmp' CHANGELOG.md
fi

echo -e "\n\nUpdate check complete. If updates are conducted, please check CHANGELOG formatting 🧐."
