#!/bin/bash

# Variables
REPO_DIR="$(pwd)"
EXHIBIT_DIR="./evidence-packet"
OUTPUT_DIR="./hashes"
OUTPUT_FILE="$OUTPUT_DIR/repo_sha256_hashes.txt"
EXHIBIT_HASHES_FILE="$OUTPUT_DIR/exhibits_sha256_hashes.txt"
FILES_HASHES_FILE="$OUTPUT_DIR/files_sha256_hashes.txt"
GPG_KEY="your-gpg-key-id"  # Replace with your GPG key ID for signing the hashes

# Create output directory
mkdir -p "$OUTPUT_DIR"

# 1. SHA-256 Hash for Entire Repository (Including Commit History)
echo "Generating SHA-256 hash for the entire repository (commit history)..."
git rev-parse HEAD > "$OUTPUT_FILE"
echo "SHA-256 of the current commit: $(cat $OUTPUT_FILE)"

# 2. SHA-256 Hash for the Files (Excluding Git History)
echo "Generating SHA-256 hashes for all files in the repository..."
git ls-files | xargs -I {} sha256sum {} > "$FILES_HASHES_FILE"
echo "SHA-256 hashes for the files saved to $FILES_HASHES_FILE"

# 3. SHA-256 Hash for the Specific Folder (e.g., Exhibits)
echo "Generating SHA-256 hashes for files in the $EXHIBIT_DIR folder..."
# find "$EXHIBIT_DIR" -type f -exec sha256sum {} \; > "$EXHIBIT_HASHES_FILE"
find . -type f -exec sha256sum {} \; > "$FILES_HASHES_FILE"

echo "SHA-256 hashes for the $EXHIBIT_DIR folder saved to $EXHIBIT_HASHES_FILE"

# 4. Optionally, Sign the Hashes with GPG
echo "Signing the hashes with your GPG key..."
gpg --armor --detach-sign --output "$OUTPUT_DIR/repo_sha256_hashes.txt.asc" "$OUTPUT_FILE"
gpg --armor --detach-sign --output "$OUTPUT_DIR/files_sha256_hashes.txt.asc" "$FILES_HASHES_FILE"
gpg --armor --detach-sign --output "$OUTPUT_DIR/exhibits_sha256_hashes.txt.asc" "$EXHIBIT_HASHES_FILE"
echo "Hashes signed and saved as .asc files."

# Final summary
echo "Summary of generated and signed hash files:"
echo "1. Repository commit hash: $OUTPUT_FILE"
echo "2. All files' SHA-256 hashes: $FILES_HASHES_FILE"
echo "3. evidence-packet folder SHA-256 hashes: $EXHIBIT_HASHES_FILE"
echo "4. Signed hash files: *.asc"

