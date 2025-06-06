#!/bin/bash

set -euo pipefail

# ------------------ CONFIG ------------------
GPG_KEY="18759C0DBE1B112F"  # Replace with your actual GPG key
TOP_LEVEL_DIR="$(pwd)"
HASH_DIR="$TOP_LEVEL_DIR/hashes"
SHA_TOOL="./gen-sha256-top-level.sh"
SUBMODULE_DIRS=("addenda-private" "emails-private" "evidence-packet")
BRANCH="main"

# ------------------ FUNCTIONS ------------------
function check_clean() {
  echo "🔍 Checking for unstaged or staged changes in main repo..."
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "❌ You have local changes in the working tree. Please commit or stash them before continuing."
    exit 1
  fi
  echo "✔️  Working tree is clean."
}

function update_main_repo() {
  echo "📥 Pulling latest changes from origin/$BRANCH..."
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
}

function update_submodules() {
  echo "🔄 Syncing and updating submodules..."
  git submodule sync --recursive
  git submodule update --init --recursive

  for dir in "${SUBMODULE_DIRS[@]}"; do
    echo "➡️  Updating submodule: $dir"
    if [ ! -d "$dir/.git" ] && [ ! -f "$dir/.git" ]; then
      echo "⚠️  Skipping $dir: not a valid submodule (missing .git)"
      continue
    fi
    pushd "$dir" > /dev/null

    # Ensure we’re on or tracking the correct branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
    if [[ "$current_branch" != "$BRANCH" ]]; then
      echo "  ⏩ Switching $dir to $BRANCH..."
      git fetch origin
      git checkout "$BRANCH" || git checkout -b "$BRANCH" "origin/$BRANCH"
    fi

    git pull origin "$BRANCH"
    echo "  ✅ $dir updated to SHA: $(git rev-parse HEAD)"

    popd > /dev/null
  done
}

function generate_shas() {
  echo "🔐 Generating top-level SHA signatures..."
  if [ ! -x "$SHA_TOOL" ]; then
    echo "⛏️  Making SHA script executable..."
    chmod +x "$SHA_TOOL"
  fi

  "$SHA_TOOL"
}

function summary() {
  echo -e "\n📦 Submodule summary:"
  git submodule status

  echo -e "\n📁 Hash artifacts:"
  ls -lh "$HASH_DIR"/*.txt "$HASH_DIR"/*.asc 2>/dev/null || echo "⚠️  No hash files found."
}

# ------------------ MAIN ------------------

check_clean
update_main_repo
update_submodules
generate_shas
summary

echo -e "\n✅ All repositories and submodules are up-to-date and SHA integrity has been refreshed."

