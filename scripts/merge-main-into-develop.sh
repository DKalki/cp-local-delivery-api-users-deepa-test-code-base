#!/usr/bin/env bash
###
# Responsible for merging main into develop
# This will temporarily de-activate branch protection to allow the merge, then re-activate it.
##

set -e
set -o pipefail

# Colours https://misc.flogisoft.com/bash/tip_colors_and_formatting
reset=$'\e[0m'
headerColour=$'\e[1;34m'

# Branch details
PRODUCTION_BRANCH=$(jq -r .productionBranch < emis.json)
HEAD_BRANCH=develop

printf "\\n%sTurning off branch protection for '${HEAD_BRANCH}'...%s\\n" "${headerColour}" "${reset}"
git checkout "${HEAD_BRANCH}"
gh api /repos/:owner/:repo/branches/:branch/protection/enforce_admins -X DELETE

printf "\\n%sMerge latest changes from '${PRODUCTION_BRANCH}' into '${HEAD_BRANCH}'...%s\\n" "${headerColour}" "${reset}"
git merge origin/"${PRODUCTION_BRANCH}"
git push

printf "\\n%sTurning on branch protection for '${HEAD_BRANCH}'...%s\\n" "${headerColour}" "${reset}"
gh api /repos/:owner/:repo/branches/:branch/protection/enforce_admins -X POST
