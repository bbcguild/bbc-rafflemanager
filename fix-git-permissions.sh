#!/bin/bash
# Fix Git permissions in dev container
# Run this script inside the dev container if you see all files as modified

echo "🔧 Fixing Git permissions in dev container..."

# Configure Git to ignore file mode changes
git config core.filemode false

# Add the workspace as a safe directory
git config --global --add safe.directory /workspaces/bbc-rafflemanager

# Reset any spurious changes
git reset --hard HEAD

# Status check
echo "✅ Git status after permission fix:"
git status --porcelain

if [ -z "$(git status --porcelain)" ]; then
    echo "🎉 All clean! No modified files showing in Git."
else
    echo "ℹ️  Some files still show as modified. This might be actual changes."
fi
