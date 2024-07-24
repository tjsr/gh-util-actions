#!/bin/bash
# INPUT_USE_LATEST={{ inputs.useLatest }}
# INPUT_DEPENDENCY=${{ inputs.dependency }}

if [ -z "$GITHUB_OUTPUT" ]; then
  if [ "$1" != "stdout" ] && [ "$2" != "stdout" ]; then
    echo "GITHUB_OUTPUT is not set. To send to stdout, use 'stdout' as param"
    exit 1
  fi
  GITHUB_OUTPUT="/dev/stdout"
fi

if [ -z "$INPUT_DEPENDENCY" ]; then
  if [ -z "$1" ]; then
    echo "'dependency/INPUT_DEPENDENCY' must be provided or specified as $1"
    exit 1
  fi
  INPUT_DEPENDENCY=$1
fi

if [ -z "$INPUT_USE_LATEST" ]; then
  echo "useLatest/INPUT_USE_LATEST is not set, defaulting to false."
  INPUT_USE_LATEST=false
fi

if [ ! -z "$SPECIFIED_VERSION" ]; then
  echo "Using version $SPECIFIED_VERSION for $INPUT_DEPENDENCY provided in parameter."
  echo "version=$SPECIFIED_VERSION" >> "$GITHUB_OUTPUT"
  echo "hasNewVersion=true" >> "$GITHUB_OUTPUT"
  echo "specified=true" >> "$GITHUB_OUTPUT"
  exit 0
else
  echo "specified=false" >> "$GITHUB_OUTPUT"
fi

if [ -z "$LATEST_VERSION" ] && [ "$INPUT_USE_LATEST" = 'true' ]; then
  echo "LATEST_VERSION is not set but INPUT_USE_LATEST is true when trying to upgrade $INPUT_DEPENDENCY.  Can not continue."
  echo "hasNewVersion=false" >> "$GITHUB_OUTPUT"
  echo "specified=false" >> "$GITHUB_OUTPUT"
  exit 1
fi

if [ -z "$WANTED_VERSION" ] && [ "$INPUT_USE_LATEST" = 'false' ]; then
  echo "WANTED_VERSION is not set but INPUT_USE_LATEST is false when trying to upgrade $INPUT_DEPENDENCY.  Can not continue."
  echo "hasNewVersion=false" >> "$GITHUB_OUTPUT"
  exit 1
fi

echo "hasNewVersion=true" >> "$GITHUB_OUTPUT"
if [ "$INPUT_USE_LATEST" = 'true' ]; then
  echo "Using latest version $LATEST_VERSION for $INPUT_DEPENDENCY retrieved from outdated."
  echo "version=$LATEST_VERSION" >> "$GITHUB_OUTPUT"
else
  echo "Using wanted version $WANTED_VERSION for $INPUT_DEPENDENCY retrieved from outdated."
  echo "version=$WANTED_VERSION" >> "$GITHUB_OUTPUT"
fi
