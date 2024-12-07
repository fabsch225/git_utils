#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <commit_message> <path_to_repos> [max_depth]"
  exit 1
fi

COMMIT_MSG="$1"
ROOT_PATH="$2"
MAX_DEPTH="${3:-1}"

is_git_repo() {
  git -C "$1" rev-parse --is-inside-work-tree &> /dev/null
}

commit_repos() {
  if [ -z "$MAX_DEPTH" ]; then
    find "$ROOT_PATH" -type d -name ".git" | while read -r git_dir; do
      repo_dir=$(dirname "$git_dir")
      git -C "$repo_dir" add .
      git -C "$repo_dir" commit -m "$COMMIT_MSG" || echo "No changes to commit in $repo_dir"
    done
  else
    find "$ROOT_PATH" -maxdepth "$MAX_DEPTH" -type d -name ".git" | while read -r git_dir; do
      repo_dir=$(dirname "$git_dir")
      git -C "$repo_dir" add .
      git -C "$repo_dir" commit -m "$COMMIT_MSG" || echo "No changes to commit in $repo_dir"
    done
  fi
}

commit_repos
