#!/bin/bash

BRANCH_NAME="dependency/${{ inputs.dependency }}/$VERSION"
BRANCH_HEAD="${{ steps.get-branch.outputs.branch }}"

prs=$(gh pr list \
    --repo "$GITHUB_REPOSITORY" \
    --head '${{ steps.get-branch.outputs.branch }}' \
    )
if [ "$prs" -gt 0 ]; then
    echo "Branch already exists at $BRANCH_NAME - no PR will be created."
    echo "exists=true" >> "$GITHUB_OUTPUT"
else
    echo "PR will be created at $BRANCH_NAME"
    echo "exists=false" >> "$GITHUB_OUTPUT"
fi
