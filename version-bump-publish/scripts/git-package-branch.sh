#!/bin/bash

set +e

if [ -z "$PACKAGE_WITH_VERSION" ]; then
  echo "PACKAGE_WITH_VERSION is not set"
  exit 1
fi

if [ -z "$PACKAGE_NAME" ]; then
  echo "PACKAGE_NAME is not set"
  exit 1
fi

if [ -z "$BASE_BRANCH" ]; then
  echo "BASE_BRANCH is not set"
  exit 1
fi

if [ -z "$WORKING_BRANCH" ]; then
  echo "WORKING_BRANCH is not set"
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch is $CURRENT_BRANCH"

echo "Adding package.json files to index for $PACKAGE_WITH_VERSION"
git add package.json package-lock.json

echo "Committing change for $PACKAGE_NAME to $PACKAGE_WITH_VERSION"
git commit -m "Update $PACKAGE_NAME to $PACKAGE_WITH_VERSION"

if [ ! -z "$REBASE_TO_MAIN" ]; then
  echo "Pulling from $BASE_BRANCH with rebase"
  git pull --rebase origin $BASE_BRANCH
else
  echo "Not rebasing to $BASE_BRANCH at this time"
fi

if [ $? -ne 0 ]; then
  echo "Failed to pull and rebase from $WORKING_BRANCH, git status command gives:"
  git status
  exit 1
fi

echo "Pushing to $WORKING_BRANCH without tags..."
git push -u origin $WORKING_BRANCH

if [ $? -ne 0 ]; then
  echo "Failed to push to $WORKING_BRANCH, git status command gives:"
  git status
  exit 1
fi
