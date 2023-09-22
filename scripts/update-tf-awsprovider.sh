#!/usr/bin/env bash
###
# Responsible for updating the AMI for the EC2 instance
##

set -e
set -o pipefail

if [[ -z "${CI}" ]]; then
		echo "Set the CI env variable."
		exit 1
fi

# What is the production branch of the project
HEAD_BRANCH=develop

# Colours https://misc.flogisoft.com/bash/tip_colors_and_formatting
reset=$'\e[0m'
headerColour=$'\e[1;34m'

printf "\\n%sFetch AMI ID from AWS SSM...%s\\n" "${headerColour}" "${reset}"
RELEASE_JSON=$(curl -s https://api.github.com/repos/hashicorp/terraform-provider-aws/releases/latest)
NEW_VERSION=$(echo "${RELEASE_JSON}" | jq --raw-output '.tag_name' | cut -c 2-)
BRANCH="awsprovider-${NEW_VERSION}"

##
# Git
##
printf "\\n%sCheck that we don't already have a PR for this...%s\\n" "${headerColour}" "${reset}"

if git branch -a | grep -q "remotes/origin/${BRANCH}"; then
	printf "\\n%sPR already exists to update aws provider to ${NEW_VERSION}, exiting...%s\\n" "${headerColour}" "${reset}"
	exit 0
fi

git fetch --all
printf "\\n%sCreate new git branch '%s'...%s\\n" "${headerColour}" "${BRANCH}" "${reset}"
git reset HEAD --hard
git checkout -b "${BRANCH}" "origin/${HEAD_BRANCH}"

##
# Make the changes
##

printf "\\n%sUpdating aws provider version to '%s'...%s\\n" "${headerColour}" "${NEW_VERSION}" "${reset}"
find deploy/aws/terraform -maxdepth 1 -name terragrunt.hcl | while IFS='' read -r file; do
	sed -i "s/version = \"[a-zA-Z0-9.]*\"/version = \"${NEW_VERSION}\"/g" "${file}"
	printf "\\n\\t%sUpdating '%s'...%s\\n" "${headerColour}" "${file}" "${reset}"
done

# ##
# # Check if there's a diff after the update.
# # If there is, raise a PR. Otherwise we go back to develop and delete the branch.
# ##

DIFF_COUNT=$(git diff --numstat | wc -l)

if [ "$DIFF_COUNT" -eq 0 ]; then
	printf "\\n%sNothing to update, checking out '%s' and deleting '%s'...%s\\n" "${headerColour}" "${HEAD_BRANCH}" "${BRANCH}" "${reset}"
	git checkout "${HEAD_BRANCH}"
	git branch -D "${BRANCH}"
else
	printf "\\n%sCommit the change to the '%s' new branch...%s\\n" "${headerColour}" "${BRANCH}" "${reset}"
	git add .

	# Only commit and push with alternate creds if running in CI mode
	if [ "${CI}" == "true" ] ; then
		git -c "user.name=${GITHUB_USER}" -c "user.email=${GITHUB_USER}@emisgroupplc.com" commit -m "chore: Update aws provider: ${NEW_VERSION}"
		git push -f  https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/emisgroup/xgp-patient-api.git
	else
		git commit -m "chore: Update aws provider: ${NEW_VERSION}" && git push origin "${BRANCH}"
	fi

	printf "\\n%sCreate a PR for the update...%s\\n" "${headerColour}" "${reset}"
	gh pr create --body "Update the aws provider used: ${NEW_VERSION}" --title "chore: Update aws provider: ${NEW_VERSION}" --head "${BRANCH}"
fi
