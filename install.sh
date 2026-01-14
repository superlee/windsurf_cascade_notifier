#!/bin/bash
# install.sh - Install Windsurf Cascade Notifier

set -euo pipefail

# Configuration
INSTALL_DIR="${HOME}/.windsurf-notifier"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINDSURF_HOOKS_FILE="${HOME}/.codeium/windsurf/hooks.json"

echo "Installing Windsurf Cascade Notifier..."

# Create installation directory
echo "Creating installation directory: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/hooks"
mkdir -p "${INSTALL_DIR}/lib"
mkdir -p "${INSTALL_DIR}/debounce"

# Copy hook scripts
echo "Installing hook scripts..."
cp "${SCRIPT_DIR}/src/hooks/"*.sh "${INSTALL_DIR}/hooks/"
chmod +x "${INSTALL_DIR}/hooks/"*.sh

# Copy library scripts
echo "Installing library scripts..."
cp "${SCRIPT_DIR}/src/lib/"*.sh "${INSTALL_DIR}/lib/"
chmod +x "${INSTALL_DIR}/lib/"*.sh

# Copy default config if user config doesn't exist
if [[ ! -f "${INSTALL_DIR}/config.json" ]]; then
    echo "Creating default configuration..."
    cp "${SCRIPT_DIR}/src/config/default-config.json" "${INSTALL_DIR}/config.json"
else
    echo "Preserving existing configuration..."
fi

# Source hooks manager for user-level hooks configuration
source "${SCRIPT_DIR}/src/lib/hooks_manager.sh"

# Configure user-level Windsurf hooks
echo "Configuring user-level Windsurf hooks..."

# Backup existing hooks.json if present
backup_hooks_json

# Merge notifier hooks into user-level hooks.json
if merge_hooks; then
    echo "User-level hooks configured at: ${WINDSURF_HOOKS_FILE}"
else
    echo "⚠️  Warning: Failed to configure user-level hooks"
    echo "   You may need to add hooks manually to: ${WINDSURF_HOOKS_FILE}"
fi

# Warn if project-level hooks.json also exists
if [[ -f ".windsurf/hooks.json" ]]; then
    echo ""
    echo "⚠️  Note: Project-level .windsurf/hooks.json also exists"
    echo "   User-level hooks (~/.codeium/windsurf/hooks.json) take precedence"
    echo "   Consider removing project-level hooks if no longer needed"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Installed to: ${INSTALL_DIR}"
echo "Hooks config: ${WINDSURF_HOOKS_FILE}"
echo ""
echo "Next steps:"
echo "1. Restart Windsurf to load the hooks"
echo "2. Test by running a command that requires password input"
echo "3. View logs: tail -f ${INSTALL_DIR}/notifications.log"
echo ""
echo "Configuration: ${INSTALL_DIR}/config.json"
