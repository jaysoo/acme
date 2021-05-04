#!/bin/bash

# This script is used in Vercel to determine whether to continue the build or not for nx-dev.
# Exits with 0 if the build should be skipped, and exits with 1 to continue.

# Configure these values to match the GitHub repo.
OWNER=jaysoo
REPO=acme

# Only arg is the app name as configured in Nx's workspace.json file.
APP=$1

# Always disable deployment to production. We will manually promote specific builds to production.
# Remove this if you want to always deploy to production from main branch.
if [ $VERCEL_GIT_COMMIT_REF == "main" ]; then
  echo ">>> 🛑 - Build cancelled (main branch requires manual promotion)"
  exit 0
fi

# Adding origin so we can use `gh` and `nx affected` commands.
git remote add origin https://github.com/$OWNER/$REPO.git

# This token must be set in Vercel settings.
# Need permissions for "repo" and "read:org".
echo $NX_GITHUB_TOKEN > token.txt

# Install GitHub CLI and log in.
yum -q install wget
wget -q https://github.com/cli/cli/releases/download/v1.9.2/gh_1.9.2_linux_386.rpm
yum -q install gh_1.9.2_linux_386.rpm
gh auth login --with-token < token.txt

# Find the matching PR and get the base ref (usually the main branch).
PR_NUMBER=$(gh api -X GET "search/issues?q=$VERCEL_GIT_COMMIT_SHA+repo:$OWNER/$REPO+type:pr+is:open" -q=".items[0].number")

if [ -z $PR_NUMBER ]; then
  echo ">>> 🛑 - Could not PR matching $VERCEL_GIT_COMMIT_SHA. Skipping build."
  exit 0
fi

BASE_REF=$(gh pr view $PR_NUMBER --json headRefName,baseRefName -q ".baseRefName")

# Fetching for Nx affected.
git fetch origin $BASE_REF
git fetch origin $VERCEL_GIT_COMMIT_SHA

if [ -z $BASE_REF ]; then
  echo ">>> 🛑 - Could not find base ref. Skipping build."
  exit 0
fi

echo ">>> ✨ - Found base ref ($BASE_REF)"

echo ">>> 🧶 - Installing Nx..."

yarn add -D @nrwl/workspace --prefer-offline

echo ">>> 📝 - Checking affected apps..."

# List affected projects, then check if it includes the app.
npx nx print-affected --base origin/$BASE_REF --head $VERCEL_GIT_COMMIT_SHA > affected.json
node -e "if (!require('./affected.json').projects.includes('$APP')) process.exit(1)"

STATUS=$?

if [ $STATUS -eq 1 ]; then
  echo ">>> 🛑 - Build cancelled"
  exit 0
elif [ $STATUS -eq 0 ]; then
  echo ">>> ✅ - Build can proceed"
  exit 1
fi
