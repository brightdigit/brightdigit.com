#!/bin/bash
# Run this script after squash-merging a branch that contains git subrepo commits.
# It updates the `parent` field in each .gitrepo file to the current HEAD commit,
# then commits the changes so future git subrepo push/pull operations work correctly.

set -e

NEW_PARENT=$(git rev-parse HEAD)
echo "Updating subrepo parent refs to: $NEW_PARENT"

find . -name ".gitrepo" -exec sed -i '' "s/^\tparent = .*/\tparent = $NEW_PARENT/" {} \;

GITREPO_FILES=$(find . -name ".gitrepo" | sort)
git add $GITREPO_FILES

if git diff --cached --quiet; then
  echo "No .gitrepo files needed updating."
else
  git commit -m "Update subrepo parent refs after squash [skip ci]"
  echo "Done. Push with: git push"
fi
