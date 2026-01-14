#!/bin/bash
# uninstall.sh - Uninstall Windsurf Cascade Notifier

set -euo pipefail

INSTALL_DIR="${HOME}/.windsurf-notifier"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINDSURF_HOOKS_FILE="${HOME}/.codeium/windsurf/hooks.json"

echo "Uninstalling Windsurf Cascade Notifier..."

# Source hooks manager for cleanup (if available)
if [[ -f "${SCRIPT_DIR}/src/lib/hooks_manager.sh" ]]; then
    source "${SCRIPT_DIR}/src/lib/hooks_manager.sh"
    
    # Remove notifier hooks from user-level hooks.json
    echo "Cleaning up user-level Windsurf hooks..."
    
    # Backup before modification
    backup_hooks_json
    
    # Remove notifier hooks
    if remove_notifier_hooks; then
        echo "Removed notifier hooks from: ${WINDSURF_HOOKS_FILE}"
    else
        echo "⚠️  Warning: Could not clean up hooks.json"
    fi
elif [[ -f "${INSTALL_DIR}/lib/hooks_manager.sh" ]]; then
    # Try installed location
    source "${INSTALL_DIR}/lib/hooks_manager.sh"
    
    echo "Cleaning up user-level Windsurf hooks..."
    backup_hooks_json
    
    if remove_notifier_hooks; then
        echo "Removed notifier hooks from: ${WINDSURF_HOOKS_FILE}"
    fi
fi

# Remove installation directory
if [[ -d "${INSTALL_DIR}" ]]; then
    echo "Removing installation directory: ${INSTALL_DIR}"
    rm -rf "${INSTALL_DIR}"
else
    echo "Installation directory not found: ${INSTALL_DIR}"
fi

echo ""
echo "✅ Uninstallation complete!"
echo ""
echo "Hooks cleaned from: ${WINDSURF_HOOKS_FILE}"
echo "Other hooks (if any) were preserved."
