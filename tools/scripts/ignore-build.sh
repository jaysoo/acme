#!/bin/bash

# This script is used in Vercel to determine whether to continue the build or not for nx-dev.
# Exits with 0 if the build should be skipped, and exits with 1 to continue.

APP=$1

#yarn add @nrwl/workspace --prefer-offline
npx nx affected:apps --plain | grep $APP -q

STATUS=$?

if [ $STATUS -eq 1 ]; then
  echo "App '$APP' not affected. Skipping build."
  exit 0
elif [ $STATUS -eq 0 ]; then
  echo "App '$APP' is affected. Continue build."
  exit 1
fi
