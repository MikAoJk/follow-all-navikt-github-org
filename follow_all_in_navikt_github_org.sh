#!/bin/bash

# Script to follow all users in navikt GitHub organization using the GitHub CLI (gh)
# Usage: ./follow_all_in_navikt_github_org.sh
# Requires: GitHub CLI (gh) installed and authenticated with the command gh auth login


# Get all members of the navikt organization (paginated)
page=1
while true; do
  # Fetch a page of members (100 per page)
  users=$(gh api "/orgs/navikt/members?per_page=100&page=$page" --jq '.[].login' 2>/dev/null)

  # Break if no users found on this page
  if [ -z "$users" ]; then
    break
  fi

  # Follow each user
  for user in $users; do
    echo "Following $user..."
    gh api -X PUT "/user/following/$user" >/dev/null 2>&1
  done

  page=$((page + 1))
done

echo "Done following all users in navikt."