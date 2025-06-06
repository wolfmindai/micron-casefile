
# Top-Level Makefile for micron-casefile

# Configuration
HASH_DIR := hashes
TOP_SCRIPT := ./gen-sha256-top-level.sh
HASH_FILE := $(HASH_DIR)/repo_sha256_hashes.txt
SIG_FILE := $(HASH_FILE).asc

.DEFAULT_GOAL := help

.PHONY: help gen sign verify clean

help:
	@echo "Usage:"
	@echo "  make gen      - Generate top-level SHA-256 summary and GPG sign it"
	@echo "  make verify   - Verify GPG signature of top-level SHA digest"
	@echo "  make clean    - Remove hash and signature artifacts"
	@echo "  make help     - Display this help message"

gen:
	$(TOP_SCRIPT)

verify:
	@if [ ! -f "$(HASH_FILE)" ] || [ ! -f "$(SIG_FILE)" ]; then \
		echo "❌ Error: Cannot verify. SHA file or signature is missing."; \
		echo "   Run 'make gen' to generate them first."; \
		exit 1; \
	fi
	@echo "🔍 Verifying GPG signature for $(HASH_FILE)..."
	@echo
	gpg --verify $(SIG_FILE) $(HASH_FILE)

clean:
	@echo "🧹 Cleaning top-level hash and signature artifacts..."
	rm -f $(HASH_FILE) $(SIG_FILE)

