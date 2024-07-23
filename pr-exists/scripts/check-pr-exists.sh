#!/bin/bash

if [ -z "$GITHUB_OUTPUT" ]; then
  if [ "$1" != "stdout" ]; then
    echo "GITHUB_OUTPUT is not set. To send to stdout, use 'stdout' as param'"
    exit 2
  fi
  GITHUB_OUTPUT="/dev/stdout"
fi

if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "GITHUB_REPOSITORY must be set"
    exit 1
fi

if [ -z "$BRANCH_NAME" ]; then
  echo "BRANCH_NAME must be set.  It must point to the name of the branch that the PR will be created to."
  exit 1
fi

echo "Checking for PR in $GITHUB_REPOSITORY at $BRANCH_NAME"

prCount=$(gh pr list \
    --repo "$GITHUB_REPOSITORY" \
    --head "$BRANCH_NAME" \
    --json number --jq '. | length'
    )

if [ "$prCount" -gt 0 ]; then
    echo "Branch already exists at $BRANCH_NAME - no PR will be created."
    echo "exists=true" >> "$GITHUB_OUTPUT"
else
    echo "PR will be created at $BRANCH_NAME"
    echo "exists=false" >> "$GITHUB_OUTPUT"
fi
