#!/bin/bash
# install.sh - Install Windsurf Cascade Notifier

set -euo pipefail

# Configuration
INSTALL_DIR="${HOME}/.windsurf-notifier"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Create Windsurf hooks configuration
WINDSURF_CONFIG_DIR=".windsurf"
HOOKS_JSON="${WINDSURF_CONFIG_DIR}/hooks.json"

if [[ ! -d "${WINDSURF_CONFIG_DIR}" ]]; then
    echo "Creating Windsurf hooks directory..."
    mkdir -p "${WINDSURF_CONFIG_DIR}"
fi

if [[ ! -f "${HOOKS_JSON}" ]]; then
    echo "Creating Windsurf hooks configuration..."
    cat > "${HOOKS_JSON}" << EOF
{
  "hooks": {
    "post_run_command": [
      {
        "command": "bash ${INSTALL_DIR}/hooks/post_run_command.sh",
        "show_output": false
      }
    ],
    "post_cascade_response": [
      {
        "command": "bash ${INSTALL_DIR}/hooks/post_cascade_response.sh",
        "show_output": false
      }
    ]
  }
}
EOF
else
    echo "Windsurf hooks.json already exists - please add hooks manually if needed."
    echo "See ${SCRIPT_DIR}/src/config/hooks.json for the required configuration."
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Installed to: ${INSTALL_DIR}"
echo ""
echo "Next steps:"
echo "1. Restart Windsurf to load the hooks"
echo "2. Test by running a command that requires password input"
echo "3. View logs: tail -f ${INSTALL_DIR}/notifications.log"
echo ""
echo "Configuration: ${INSTALL_DIR}/config.json"
