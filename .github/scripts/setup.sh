#!/usr/bin/env bash
set -euo pipefail

# Setup script for clearml/clearml-docs Docusaurus i18n
# Docusaurus 3.9.2, npm (lockfileVersion 3), Node 20+

REPO_URL="https://github.com/clearml/clearml-docs.git"
BRANCH="main"

# ── Node ──────────────────────────────────────────────────────────────────────
export PATH="/usr/local/bin:/usr/bin:/bin"
NODE_VERSION=$(node --version 2>/dev/null || echo "none")
echo "Node version: $NODE_VERSION"
echo "npm version: $(npm --version 2>/dev/null || echo 'none')"

# ── Clone ─────────────────────────────────────────────────────────────────────
echo "Cloning $REPO_URL (branch: $BRANCH)..."
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" source-repo

# ── Apply fixes.json patches ───────────────────────────────────────────────────
# fixes.json lives next to this script; apply it with Python before install
FIXES_JSON="$(dirname "$0")/fixes.json"
if [ -f "$FIXES_JSON" ]; then
  echo "Applying fixes from fixes.json..."
  python3 - "$FIXES_JSON" source-repo <<'PYEOF'
import json, sys, pathlib

fixes_path = sys.argv[1]
repo_root  = pathlib.Path(sys.argv[2])

with open(fixes_path, encoding="utf-8") as fh:
    config = json.load(fh)

for rel_path, patches in config.get("fixes", {}).items():
    target = repo_root / rel_path
    if not target.exists():
        print(f"  [WARN] {rel_path} not found, skipping")
        continue
    text = target.read_text(encoding="utf-8")
    for patch in patches:
        find    = patch["find"]
        replace = patch["replace"]
        if find in text:
            text = text.replace(find, replace, 1)
            print(f"  [FIX] Applied patch to {rel_path}: {patch.get('comment','')}")
        else:
            print(f"  [WARN] Pattern not found in {rel_path}: {find[:60]!r}")
    target.write_text(text, encoding="utf-8")

print("fixes.json patches applied.")
PYEOF
fi

# ── Install deps ──────────────────────────────────────────────────────────────
cd source-repo

echo "Installing dependencies..."
npm install --legacy-peer-deps

# docusaurus-gtm-plugin is referenced in docusaurus.config.js but missing from package.json
echo "Installing missing docusaurus-gtm-plugin..."
npm install --legacy-peer-deps docusaurus-gtm-plugin

# ── write-translations ────────────────────────────────────────────────────────
echo "Running write-translations..."
npx docusaurus write-translations

echo "SUCCESS: write-translations completed"
if [ -d "i18n" ]; then
  COUNT=$(find i18n -type f -name "*.json" | wc -l)
  echo "Generated $COUNT JSON files"
  find i18n -type f -name "*.json" | head -20
else
  echo "ERROR: i18n directory not found"
  exit 1
fi
