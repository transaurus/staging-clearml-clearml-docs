#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/clearml/clearml-docs"
BRANCH="main"
REPO_DIR="source-repo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Clone (skip if already exists) ---
if [ ! -d "$REPO_DIR" ]; then
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

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

# --- Apply fixes.json if present ---
FIXES_JSON="$SCRIPT_DIR/fixes.json"
if [ -f "$FIXES_JSON" ]; then
    echo "[INFO] Applying content fixes..."
    node -e "
    const fs = require('fs');
    const path = require('path');
    const fixes = JSON.parse(fs.readFileSync('$FIXES_JSON', 'utf8'));
    for (const [file, ops] of Object.entries(fixes.fixes || {})) {
        if (!fs.existsSync(file)) { console.log('  skip (not found):', file); continue; }
        let content = fs.readFileSync(file, 'utf8');
        for (const op of ops) {
            if (op.type === 'replace' && content.includes(op.find)) {
                content = content.split(op.find).join(op.replace || '');
                console.log('  fixed:', file, '-', op.comment || '');
            }
        }
        fs.writeFileSync(file, content);
    }
    for (const [file, cfg] of Object.entries(fixes.newFiles || {})) {
        const c = typeof cfg === 'string' ? cfg : cfg.content;
        fs.mkdirSync(path.dirname(file), {recursive: true});
        fs.writeFileSync(file, c);
        console.log('  created:', file);
    }
    "
fi

# --- Fix duplicate sidebar translation keys in sidebars.js ---
# sidebars.js has duplicate category labels within the same sidebar which cause
# write-translations to fail. Add unique 'key' attributes to all duplicates.
# Affected sidebars:
#   rnSidebar: Open Source (2x), Enterprise (2x), Older Versions (6x)
#   referenceSidebar: Hyper-Datasets (2x)
#   installationSidebar: Deployment Options (2x)
echo "[INFO] Fixing duplicate sidebar translation keys..."
node << 'NODESCIPT'
const fs = require('fs');
let content = fs.readFileSync('sidebars.js', 'utf8');

// ---- rnSidebar fixes ----
// rnSidebar > Server > Open Source (shorthand -> explicit with key)
content = content.replace(
    "            {\n                'Open Source':\n                        [\n                           'release_notes/clearml_server/open_source/",
    "            {type: 'category', label: 'Open Source', key: 'rn-server-open-source', items: [\n                           'release_notes/clearml_server/open_source/"
);
// rnSidebar > Server > Enterprise (shorthand -> explicit with key)
content = content.replace(
    "            {\n                'Enterprise':\n                        [\n                           'release_notes/clearml_server/enterprise/",
    "            {type: 'category', label: 'Enterprise', key: 'rn-server-enterprise', items: [\n                           'release_notes/clearml_server/enterprise/"
);
// rnSidebar > SDK > Open Source (shorthand -> explicit with key)
content = content.replace(
    "            {\n                'Open Source':\n                        [\n                           'release_notes/sdk/open_source/",
    "            {type: 'category', label: 'Open Source', key: 'rn-sdk-open-source', items: [\n                           'release_notes/sdk/open_source/"
);
// rnSidebar > SDK > Enterprise (shorthand -> explicit with key)
content = content.replace(
    "            {\n                'Enterprise':\n                        [\n                           'release_notes/sdk/enterprise/",
    "            {type: 'category', label: 'Enterprise', key: 'rn-sdk-enterprise', items: [\n                           'release_notes/sdk/enterprise/"
);

// rnSidebar: Older Versions duplicates — need unique keys for each occurrence
// We'll number them sequentially using a counter
let olderVersionsCount = 0;
content = content.replace(/\{\s*\n(\s*)'Older Versions':\s*\[/g, (match, indent) => {
    olderVersionsCount++;
    return `{\n${indent}type: 'category', label: 'Older Versions', key: 'rn-older-versions-${olderVersionsCount}', items: [`;
});

// ---- referenceSidebar fixes ----
// referenceSidebar > Hyper-Datasets #1 (link to hyperdatasets/overview)
content = content.replace(
    "label: 'Hyper-Datasets',\n            link: {type: 'doc', id: 'hyperdatasets/overview'}",
    "label: 'Hyper-Datasets',\n            key: 'ref-hpd-main',\n            link: {type: 'doc', id: 'hyperdatasets/overview'}"
);
// referenceSidebar > Hyper-Datasets #2 (link to references/hpd_overview)
content = content.replace(
    "label: 'Hyper-Datasets',\n                link: {type: 'doc', id: 'references/hpd_overview'}",
    "label: 'Hyper-Datasets',\n                key: 'ref-hpd-sdk',\n                link: {type: 'doc', id: 'references/hpd_overview'}"
);

// ---- installationSidebar fixes ----
// installationSidebar > Open Source Server > Deployment Options
content = content.replace(
    "                {'Deployment Options': [\n                    'deploying_clearml/clearml_server_aws_ec2_ami',",
    "                {type: 'category', label: 'Deployment Options', key: 'install-os-deploy-options', items: [\n                    'deploying_clearml/clearml_server_aws_ec2_ami',"
);
// installationSidebar > Enterprise Server > Deployment Options
content = content.replace(
    "                {'Deployment Options': [\n                    {\n                       type: 'category',",
    "                {type: 'category', label: 'Deployment Options', key: 'install-ent-deploy-options', items: [\n                    {\n                       type: 'category',"
);

fs.writeFileSync('sidebars.js', content);
console.log('  sidebars.js duplicate keys fixed (rnSidebar, referenceSidebar, installationSidebar)');
NODESCIPT

echo "[DONE] Repository is ready for docusaurus commands."
