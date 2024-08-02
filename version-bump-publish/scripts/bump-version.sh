#!/bin/bash

if [ -z "$GITHUB_OUTPUT" ]; then
  GITHUB_OUTPUT="/dev/stdout"
fi

if [ -z "$PATCHLEVEL" ]; then
  echo "PATCHLEVEL is not set. Please set the PATCHLEVEL environment variable of patchlevel action input."
  exit 1
fi

if [ -z "$PACKAGE_NAME" ]; then
  echo "PACKAGE_NAME is not set. Please set the PACKAGE_NAME environment variable of current-package step output."
  exit 1
fi

if [ "$NO_TAG" = "true" ] || [ "$NO_TAG" = "--no-git-tag-version" ]; then
  NO_TAG="--no-git-tag-version"
else
  NO_TAG=""
fi

if [ -z "$NEXT_VERSION_NUMBER" ]; then
  if [ -z "$BRANCH_VERSION" ]; then
    echo "BRANCH_VERSION is not set. Please set the BRANCH_VERSION or NEXT_VERSION_NUMBER."
    exit 1
  fi
  if [ "$PREID" = "release" ]; then
    PREID_SWITCH=""
  elif [ ! -z "$PREID" ]; then
    echo "Using prerelease identifier: $PREID"
    PREID_SWITCH="--preid $PREID"
  else
    PREID_SWITCH="--preid dev"
  fi

  NEXT_VERSION_NUMBER=$(npx semver --increment $PATCHLEVEL $PREID_SWITCH $BRANCH_VERSION)
fi

npm version $NEXT_VERSION_NUMBER $NO_TAG
echo "version=$NEXT_VERSION_NUMBER" >> "$GITHUB_OUTPUT"
echo "fullVersion=$PACKAGE_NAME@$NEXT_VERSION_NUMBER" >> "$GITHUB_OUTPUT"
echo "Project version number bumped to $PACKAGE_NAME@$NEXT_VERSION_NUMBER"

echo "Checking git status"
git status