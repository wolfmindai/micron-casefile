# SHA-256 Strategy for the Micron Casefile Repository

This document outlines the SHA-256 integrity plan across the `micron-casefile` repository and its critical submodule, `evidence-packet`. The goal is to ensure reproducibility, verifiability, and secure authorship for regulatory and legal submission.

---

## 🔐 Overview

There are **two distinct scopes** of hash verification:

1. **Evidence-Level Integrity (evidence-packet/)**
   - Comprehensive hashing of all submitted files and folders.
   - GPG signature for hash manifest to validate authorship and content fixity.
2. **Repository-Level Metadata (micron-casefile/)**
   - Git commit hash to track submodule SHA state.
   - Optional repository-wide file hash list for traceability.

---

## 🧾 Hashing in `evidence-packet/`

### Key Artifacts:
- `exhibits_sha256_hashes.txt`: Hash of every file in `evidence-packet/`
- `exhibits_sha256_hashes.txt.asc`: GPG-signed manifest
- [`Makefile`](../evidence-packet/Makefile): Automated workflow for hashing and signing
- Optional: `gen-sha256-evidence.sh` — legacy script, replaced by Makefile

### Workflow:
```bash
# From inside evidence-packet/
make hash    # Generates hashes
make sign    # GPG-signs the hash manifest

