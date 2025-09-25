#!/bin/bash

# Script to follow all users in navikt GitHub organization using the GitHub CLI (gh)
# Usage: ./follow_all_in_navikt_github_org.sh [--dry-run]
# Requires: GitHub CLI (gh) installed and authenticated

ORG="navikt"
PER_PAGE=100
DELAY=0.5 # seconds between follow requests
page=1
dry_run=0
failures=()

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    dry_run=1
  fi
done

# Check for gh CLI
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI (gh) is not installed. Aborting."
  exit 1
fi

# Check authentication
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: GitHub CLI is not authenticated. Run 'gh auth login' first."
  exit 1
fi

echo "Starting to follow all users in $ORG..."

while true; do
  users=$(gh api "/orgs/$ORG/members?per_page=$PER_PAGE&page=$page" --jq '.[].login' 2>/dev/null)
  if [ -z "$users" ]; then
    break
  fi

  for user in $users; do
    echo "Processing $user..."
    if [ "$dry_run" -eq 1 ]; then
      echo "Dry run: would follow $user"
    else
      gh api -X PUT "/user/following/$user" >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "Followed $user"
      else
        echo "Failed to follow $user"
        failures+=("$user")
      fi
      sleep "$DELAY"
    fi
  done

  page=$((page + 1))
done

if [ ${#failures[@]} -ne 0 ]; then
  echo "Some users could not be followed:"
  for u in "${failures[@]}"; do
    echo "  $u"
  done
fi

echo "Done following all users in $ORG."
