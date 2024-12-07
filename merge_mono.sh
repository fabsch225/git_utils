#!/bin/bash

set -e

usage() {
    echo "Usage: $0 <monorepo-directory> <repos-directory>"
    echo "  <monorepo-directory>: The path to the monorepo to create."
    echo "  <repos-directory>: The directory containing nested repositories to include in the monorepo."
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

MONOREPO_DIR=$(realpath "$1")
REPOS_DIR=$(realpath "$2")

if [ ! -d "$REPOS_DIR" ]; then
    echo "Error: Repos directory '$REPOS_DIR' does not exist."
    exit 1
fi

if [ ! -d "$MONOREPO_DIR" ]; then
    echo "Creating monorepo directory at '$MONOREPO_DIR'"
    mkdir -p "$MONOREPO_DIR"
fi

if [ ! -d "$MONOREPO_DIR/.git" ]; then
    echo "Initializing git repository in monorepo directory."
    git init "$MONOREPO_DIR"
fi

cd "$MONOREPO_DIR"

merge_repo() {
    local repo_path=$1
    local subdir=$2

    echo "Merging repository '$repo_path' into subdirectory '$subdir'"

    TMP_DIR=$(mktemp -d)
    git clone "$repo_path" "$TMP_DIR"

    mkdir -p "$subdir"
    rsync -a --exclude='.git' "$TMP_DIR/" "$subdir/"

    pushd "$TMP_DIR" > /dev/null
    git add -A

    rsync -a --exclude='.git' "$TMP_DIR/" "$MONOREPO_DIR/$subdir/"
    popd > /dev/null

    git add "$subdir"
    git commit -m "Merged repository '$repo_path' into '$subdir'"

    rm -rf "$TMP_DIR"
}

find "$REPOS_DIR" -name ".git" | while read -r repo_git_dir; do
    REPO_DIR=$(dirname "$repo_git_dir")

    RELATIVE_PATH=${REPO_DIR#$REPOS_DIR/}

    merge_repo "$REPO_DIR" "$RELATIVE_PATH"

done

echo "Finalizing the monorepo."
git commit -m "Merged all repositories into monorepo."
echo "Monorepo creation complete."
