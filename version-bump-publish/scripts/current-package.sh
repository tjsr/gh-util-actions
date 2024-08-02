#!/bin/bash

if [ ! -f "package.json" ]; then
  echo "package.json file not found in $PWD"
  exit 1
fi

if [ -z "$GITHUB_OUTPUT" ]; then
  GITHUB_OUTPUT="/dev/stdout"
fi

PACKAGE_VERSION_NUMBER=$(cat package.json | jq -r '.version')
PACKAGE_NAME=$(cat package.json | jq -r '.name')

if [ -z "$PATCHLEVEL" ]; then
  echo "PATCHLEVEL is not set. Please set the PATCHLEVEL environment variable or patchlevel action input."
  exit 1
fi

if [ "$PREID" = "release" ]; then
  PREID_SWITCH=""
elif [ ! -z "$PREID" ]; then
  echo "Using prerelease identifier: $PREID, --preid $PREID"
  PREID_SWITCH="--preid $PREID"
else
  echo "Using default preid, --preid dev"
  PREID_SWITCH="--preid dev"
fi

PUBLISHED_VERSIONS=$(npm view "$PACKAGE_NAME" versions --json |jq -r '.[]' | tr '\n' ' ' | awk '{$1=$1; print}')
if [ -z "$PUBLISHED_VERSIONS" ]; then
  echo "No published versions found for this package"
  exit 1
fi
# echo "Versions published for this package: $PUBLISHED_VERSIONS"
MATCHING_BRANCH_VERSION=$(npx semver -p $PREID_SWITCH -r ">= $PACKAGE_VERSION_NUMBER" $PUBLISHED_VERSIONS |tail -1)
if [ -z "$MATCHING_BRANCH_VERSION" ]; then
  echo "No matching version found for $PACKAGE_NAME@$PACKAGE_VERSION_NUMBER"
  echo PUBLISHED_VERSIONS from npm view was: $PUBLISHED_VERSIONS
  exit 1
fi

NEXT_VERSION_NUMBER=$(npx semver --increment $PATCHLEVEL $PREID_SWITCH $MATCHING_BRANCH_VERSION)
echo "Got latest version for $PACKAGE_NAME@$PACKAGE_VERSION_NUMBER => $MATCHING_BRANCH_VERSION"

echo "Current package $PACKAGE_NAME version number is $PACKAGE_VERSION_NUMBER"
echo "Next version matching $MATCHING_BRANCH_VERSION should be $NEXT_VERSION_NUMBER"
echo "version=$PACKAGE_VERSION_NUMBER" >> "$GITHUB_OUTPUT"
echo "name=$PACKAGE_NAME" >> "$GITHUB_OUTPUT"
echo "branchLatest=$MATCHING_BRANCH_VERSION" >> "$GITHUB_OUTPUT"
echo "nextVersion=$NEXT_VERSION_NUMBER" >> "$GITHUB_OUTPUT"
