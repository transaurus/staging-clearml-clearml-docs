#!/usr/bin/env bash
set -euo pipefail

# Rebuild script for clearml/clearml-docs
# Runs on existing source tree (no clone). Installs deps, runs pre-build steps, builds.

# --- Node version ---
# clearml/clearml-docs uses Docusaurus 3.9.2 which requires Node 18+
NODE_MAJOR=$(node --version | sed 's/v//' | cut -d. -f1)
echo "[INFO] Using Node $(node --version)"
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo "[ERROR] Node $NODE_MAJOR detected, but Docusaurus 3.x requires Node >=18."
    exit 1
fi

# --- Package manager + dependencies ---
# Uses npm (package-lock.json present)
npm ci

# --- Build ---
npm run build

echo "[DONE] Build complete."
