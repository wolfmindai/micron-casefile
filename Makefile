# Top-Level Makefile for micron-casefile

# Configuration
HASH_DIR := hashes
TOP_SCRIPT := ./gen-sha256-top-level.sh
UPDATE_SCRIPT := ./update-everything.sh
HASH_FILE := $(HASH_DIR)/repo_sha256_hashes.txt
SIG_FILE := $(HASH_FILE).asc

.DEFAULT_GOAL := help

.PHONY: help gen sign verify clean sync

help:
	@echo "📘 Usage: SHA-256 Integrity and Sync Pipeline"
	@echo ""
	@echo " 🔁 Step-by-step workflow:"
	@echo "   1. make sync     - Pulls latest from all repos and submodules, refreshes SHA state"
	@echo "   2. make verify   - Verifies the signed SHA digest from last sync"
	@echo "   3. make clean    - Deletes all SHA artifacts if you want to reset"
	@echo ""
	@echo " 🔧 Other available targets:"
	@echo "   make gen         - Generate top-level SHA-256 digest and sign it (run manually)"
	@echo "   make help        - Show this message"

sync:
	@echo "🔄 Running full sync and SHA update..."
	$(UPDATE_SCRIPT)

gen:
	@$(TOP_SCRIPT)

verify:
	@if [ ! -f "$(HASH_FILE)" ] || [ ! -f "$(SIG_FILE)" ]; then \
		echo "❌ Error: Cannot verify. SHA file or signature is missing."; \
		echo "   Run 'make gen' to generate them first."; \
		exit 1; \
	fi
	@echo "🔍 Verifying GPG signature for $(HASH_FILE)..."
	@echo
	@gpg --verify $(SIG_FILE) $(HASH_FILE)

clean:
	@echo "🧹 Cleaning top-level hash and signature artifacts..."
	@rm -f $(HASH_DIR)/*.txt $(HASH_DIR)/*.asc $(HASH_DIR)/.gitignore

