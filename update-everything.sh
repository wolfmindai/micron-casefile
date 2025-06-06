
#!/bin/bash

set -euo pipefail

# ------------------ CONFIG ------------------
GPG_KEY="18759C0DBE1B112F"  # Replace with your actual GPG key
TOP_LEVEL_DIR="$(pwd)"
HASH_DIR="$TOP_LEVEL_DIR/hashes"
SHA_TOOL="./gen-sha256-top-level.sh"
SUBMODULE_DIRS=("addenda-private" "emails-private" "evidence-packet")
BRANCH="main"

# ------------------ COLORS ------------------
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# ------------------ FUNCTIONS ------------------

function info()    { echo -e "${YELLOW}$1${NC}"; }
function success() { echo -e "${GREEN}$1${NC}"; }
function error()   { echo -e "${RED}$1${NC}"; }

function check_clean() {
  info "🔍 Checking for a clean working state..."

  if ! git diff --quiet || ! git diff --cached --quiet; then
    error "❌ You have staged or unstaged changes. Please commit or stash them first."
    exit 1
  fi

  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    error "❌ You have untracked files. Please commit, ignore, or remove them first."
    exit 1
  fi

  success "✔ Working tree is clean."
}

function update_main_repo() {
  info "📥 Pulling latest changes from origin/$BRANCH..."
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
}

function update_submodules() {
  info "🔄 Syncing and updating submodules..."
  git submodule sync --recursive
  git submodule update --init --recursive

  for dir in "${SUBMODULE_DIRS[@]}"; do
    info "➡️  Updating submodule: $dir"
    if [ ! -d "$dir/.git" ] && [ ! -f "$dir/.git" ]; then
      error "⚠️  Skipping $dir: not a valid submodule (missing .git)"
      continue
    fi

    pushd "$dir" > /dev/null

    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
    if [[ "$current_branch" != "$BRANCH" ]]; then
      info "  ⏩ Switching $dir to $BRANCH..."
      git fetch origin
      git checkout "$BRANCH" || git checkout -b "$BRANCH" "origin/$BRANCH"
    fi

    git pull origin "$BRANCH"
    success "  ✅ $dir updated to SHA: $(git rev-parse HEAD)"
    popd > /dev/null
  done
}

function generate_shas() {
  info "🔐 Generating top-level SHA signatures..."
  if [ ! -x "$SHA_TOOL" ]; then
    info "⛏️  Making SHA script executable..."
    chmod +x "$SHA_TOOL"
  fi

  "$SHA_TOOL"
}

function regenerate_submission_hashes() {
  info "🧩 Running 'make hash && make sign' inside evidence-packet/..."
  if [ -f evidence-packet/Makefile ]; then
    pushd evidence-packet > /dev/null
    make clean
    make hash
    make sign
    popd > /dev/null
    success "✔ evidence-packet SHA256 signatures refreshed."
  else
    error "⚠️  Makefile not found in evidence-packet/. Skipping SHA regeneration."
  fi
}

function summary() {
  echo -e "\n📦 Submodule summary:"
  git submodule status

  echo -e "\n📁 Hash artifacts in $HASH_DIR:"
  ls -lh "$HASH_DIR"/*.txt "$HASH_DIR"/*.asc 2>/dev/null || error "⚠️  No hash files found."

  echo -e "\n🕒 Completed on: $(date)"
}

# ------------------ MAIN ------------------

info "🚀 Starting multi-repo sync + SHA integrity pipeline..."
check_clean
update_main_repo
update_submodules
generate_shas
regenerate_submission_hashes
summary

success "\n✅ All repositories and submodules are up-to-date and SHA integrity has been refreshed."

