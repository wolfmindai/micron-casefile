#!/bin/bash

set -euo pipefail

# --- Configuration ---
OUTPUT_DIR="./hashes"
OUTPUT_FILE="$OUTPUT_DIR/repo_sha256_hashes.txt"
GPG_KEY="18759C0DBE1B112F"  # <-- REPLACE with your actual GPG key ID

# --- Create output directory ---
mkdir -p "$OUTPUT_DIR"

# --- Generate current HEAD commit SHA ---
echo "[✔] Recording HEAD commit SHA..."
{
  echo "Repository HEAD Commit:"
  git rev-parse HEAD
  echo
} > "$OUTPUT_FILE"

# --- Record submodule SHAs ---
echo "[✔] Recording submodule SHAs..."
{
  echo "Submodule SHAs:"
  git submodule status --recursive
  echo
} >> "$OUTPUT_FILE"

# --- Hash .gitmodules file (if present) ---
if [ -f .gitmodules ]; then
  echo "[✔] Hashing .gitmodules..."
  echo "SHA-256 of .gitmodules:" >> "$OUTPUT_FILE"
  sha256sum .gitmodules >> "$OUTPUT_FILE"
  echo >> "$OUTPUT_FILE"
fi

# --- GPG Sign the summary ---
echo "[✔] Signing SHA summary with GPG key $GPG_KEY..."
gpg --armor --detach-sign --local-user "$GPG_KEY" --output "${OUTPUT_FILE}.asc" "$OUTPUT_FILE"

# --- Done ---
echo ""
echo "✅ Top-level SHA report written to: $OUTPUT_FILE"
echo "🔏 GPG signature created at: ${OUTPUT_FILE}.asc"

