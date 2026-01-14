#!/bin/bash
# uninstall.sh - Uninstall Windsurf Cascade Notifier

set -euo pipefail

INSTALL_DIR="${HOME}/.windsurf-notifier"

echo "Uninstalling Windsurf Cascade Notifier..."

# Remove installation directory
if [[ -d "${INSTALL_DIR}" ]]; then
    echo "Removing installation directory: ${INSTALL_DIR}"
    rm -rf "${INSTALL_DIR}"
else
    echo "Installation directory not found: ${INSTALL_DIR}"
fi

# Note about hooks.json
echo ""
echo "⚠️  Note: The .windsurf/hooks.json file was not removed."
echo "   If you want to remove the hooks configuration, delete it manually:"
echo "   rm .windsurf/hooks.json"
echo ""
echo "✅ Uninstallation complete!"
