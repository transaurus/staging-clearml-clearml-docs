#!/usr/bin/env node
/**
 * Apply repository-specific fixes after syncing from source
 * This file is deployed and customized per repository by run_phase1_sync.py
 */

const fs = require('fs');
const path = require('path');

// Repository-specific fixes will be injected here by run_phase1_sync.py
const fixes = {
  "sidebars.js": [
    {
      "type": "replace",
      "find": "'Open Source':\n                        [\n                           'release_notes/clearml_server/open_source/ver_2_4'",
      "replace": "type: 'category', label: 'Open Source', key: 'rn-server-open-source', items:\n                        [\n                           'release_notes/clearml_server/open_source/ver_2_4'",
      "comment": "Add unique key to Server > Open Source category to avoid duplicate translation key with SDK > Open Source"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                                   'release_notes/clearml_server/open_source/ver_2_3'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-server-os-older', items: [\n                                   'release_notes/clearml_server/open_source/ver_2_3'",
      "comment": "Add unique key to Server > Open Source > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Enterprise':\n                        [\n                           'release_notes/clearml_server/enterprise/ver_3_28'",
      "replace": "type: 'category', label: 'Enterprise', key: 'rn-server-enterprise', items:\n                        [\n                           'release_notes/clearml_server/enterprise/ver_3_28'",
      "comment": "Add unique key to Server > Enterprise category to avoid duplicate translation key with SDK > Enterprise"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                                     'release_notes/clearml_server/enterprise/ver_3_27'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-server-ent-older', items: [\n                                     'release_notes/clearml_server/enterprise/ver_3_27'",
      "comment": "Add unique key to Server > Enterprise > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Open Source':\n                        [\n                           'release_notes/sdk/open_source/ver_2_1'",
      "replace": "type: 'category', label: 'Open Source', key: 'rn-sdk-open-source', items:\n                        [\n                           'release_notes/sdk/open_source/ver_2_1'",
      "comment": "Add unique key to SDK > Open Source category to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                                   'release_notes/sdk/open_source/ver_2_0'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-sdk-os-older', items: [\n                                   'release_notes/sdk/open_source/ver_2_0'",
      "comment": "Add unique key to SDK > Open Source > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Enterprise':\n                        [\n                           'release_notes/sdk/enterprise/ver_3_14'",
      "replace": "type: 'category', label: 'Enterprise', key: 'rn-sdk-enterprise', items:\n                        [\n                           'release_notes/sdk/enterprise/ver_3_14'",
      "comment": "Add unique key to SDK > Enterprise category to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                                   'release_notes/sdk/enterprise/ver_3_13'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-sdk-ent-older', items: [\n                                   'release_notes/sdk/enterprise/ver_3_13'",
      "comment": "Add unique key to SDK > Enterprise > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                        'release_notes/clearml_agent/ver_1_9'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-agent-older', items: [\n                        'release_notes/clearml_agent/ver_1_9'",
      "comment": "Add unique key to ClearML Agent > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Older Versions': [\n                        'release_notes/clearml_serving/ver_1_2'",
      "replace": "type: 'category', label: 'Older Versions', key: 'rn-serving-older', items: [\n                        'release_notes/clearml_serving/ver_1_2'",
      "comment": "Add unique key to ClearML Serving > Older Versions to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "label: 'Hyper-Datasets',\n                link: {type: 'doc', id: 'references/hpd_overview'},",
      "replace": "label: 'Hyper-Datasets',\n                key: 'ref-hyper-datasets-references',\n                link: {type: 'doc', id: 'references/hpd_overview'},",
      "comment": "Add unique key to referenceSidebar Hyper-Datasets (references section) to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Hyper-Datasets': [\n                    'hyperdatasets/webapp/webapp_datasets',",
      "replace": "type: 'category', label: 'Hyper-Datasets', key: 'ref-hyper-datasets-webapp', items: [\n                    'hyperdatasets/webapp/webapp_datasets',",
      "comment": "Add unique key to referenceSidebar Hyper-Datasets (webapp section) to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Deployment Options': [\n                    'deploying_clearml/clearml_server_aws_ec2_ami',",
      "replace": "type: 'category', label: 'Deployment Options', key: 'install-os-deploy-opts', items: [\n                    'deploying_clearml/clearml_server_aws_ec2_ami',",
      "comment": "Add unique key to installationSidebar Open Source Deployment Options to avoid duplicate translation key"
    },
    {
      "type": "replace",
      "find": "'Deployment Options': [\n                    {\n                       type: 'category',",
      "replace": "type: 'category', label: 'Deployment Options', key: 'install-ent-deploy-opts', items: [\n                    {\n                       type: 'category',",
      "comment": "Add unique key to installationSidebar Enterprise Deployment Options to avoid duplicate translation key"
    }
  ]
};
const newFiles = {};

function applyFixes() {
  console.log('Applying repository-specific fixes...');

  // Apply file modifications
  for (const [filePath, operations] of Object.entries(fixes)) {
    if (!fs.existsSync(filePath)) {
      console.log(`  ⚠️ File not found: ${filePath}`);
      continue;
    }

    console.log(`  Fixing ${filePath}...`);
    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;

    for (const op of operations) {
      switch (op.type) {
        case 'replace':
          if (content.includes(op.find)) {
            // Handle special case of replacing with empty string (deletion)
            const replacement = op.replace || '';
            // Use split/join for literal string replacement
            content = content.split(op.find).join(replacement);
            modified = true;
            console.log(`    ✓ Replaced pattern${op.comment ? ': ' + op.comment : ''}`);
          }
          break;

        case 'delete_lines':
          const lines = content.split('\n');
          lines.splice(op.startLine - 1, op.endLine - op.startLine + 1);
          content = lines.join('\n');
          modified = true;
          console.log(`    ✓ Deleted lines ${op.startLine}-${op.endLine}${op.comment ? ': ' + op.comment : ''}`);
          break;

        case 'insert_after_line':
          const insertLines = content.split('\n');
          insertLines.splice(op.line, 0, op.content);
          content = insertLines.join('\n');
          modified = true;
          console.log(`    ✓ Inserted content after line ${op.line}${op.comment ? ': ' + op.comment : ''}`);
          break;

        case 'delete_file':
          fs.unlinkSync(filePath);
          console.log(`    ✓ Deleted file${op.comment ? ': ' + op.comment : ''}`);
          modified = false; // Mark as not modified to skip write
          break; // Continue to next file instead of returning
      }
    }

    if (modified) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`    ✓ File updated`);
    }
  }

  // Create new files
  for (const [filePath, fileConfig] of Object.entries(newFiles)) {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    const fileContent = typeof fileConfig === 'string' ? fileConfig : fileConfig.content;
    fs.writeFileSync(filePath, fileContent, 'utf8');
    console.log(`  ✓ Created ${filePath}${fileConfig.comment ? ': ' + fileConfig.comment : ''}`);
  }

  console.log('Repository-specific fixes applied successfully.');
}

// Main execution
try {
  if (Object.keys(fixes).length === 0 && Object.keys(newFiles).length === 0) {
    console.log('No repository-specific fixes to apply.');
    process.exit(0);
  }

  applyFixes();
  process.exit(0);
} catch (error) {
  console.error('Error applying fixes:', error);
  console.error(error.stack);
  process.exit(1);
}
