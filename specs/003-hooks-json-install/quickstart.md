# Quickstart: Hooks.json Install/Uninstall Management

## What This Feature Does

Updates the installer to automatically configure Windsurf's user-level hooks at `~/.codeium/windsurf/hooks.json`. This enables the notifier to work globally across all projects without per-project configuration.

## Installation

Run the installer:

```bash
./install.sh
```

This will:
1. Copy notifier scripts to `~/.windsurf-notifier/`
2. Create/update `~/.codeium/windsurf/hooks.json` with notifier hooks
3. Preserve any existing hooks from other tools

## Verification Tests

### Test 1: Fresh Install (No Existing hooks.json)

1. Ensure `~/.codeium/windsurf/hooks.json` doesn't exist (or rename it)
2. Run `./install.sh`
3. **Expected**: File created with notifier hooks
4. **Verify**: 
   ```bash
   cat ~/.codeium/windsurf/hooks.json | jq '.hooks.post_run_command'
   ```
   Should show entry with `~/.windsurf-notifier/hooks/post_run_command.sh`

### Test 2: Install with Existing Hooks

1. Create a hooks.json with other hooks:
   ```bash
   mkdir -p ~/.codeium/windsurf
   cat > ~/.codeium/windsurf/hooks.json << 'EOF'
   {
     "hooks": {
       "post_run_command": [
         {"command": "bash /some/other/hook.sh", "show_output": false}
       ]
     }
   }
   EOF
   ```
2. Run `./install.sh`
3. **Expected**: Both hooks present (original + notifier)
4. **Verify**:
   ```bash
   cat ~/.codeium/windsurf/hooks.json | jq '.hooks.post_run_command | length'
   ```
   Should show `2`

### Test 3: Idempotent Install

1. Run `./install.sh` twice
2. **Expected**: No duplicate entries
3. **Verify**:
   ```bash
   cat ~/.codeium/windsurf/hooks.json | jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length'
   ```
   Should show `1` (not 2)

### Test 4: Clean Uninstall

1. Run `./uninstall.sh`
2. **Expected**: Notifier hooks removed, other hooks preserved
3. **Verify**:
   ```bash
   cat ~/.codeium/windsurf/hooks.json | jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length'
   ```
   Should show `0`

### Test 5: Uninstall Preserves Other Hooks

1. After Test 2, run `./uninstall.sh`
2. **Expected**: Original `/some/other/hook.sh` still present
3. **Verify**:
   ```bash
   cat ~/.codeium/windsurf/hooks.json | jq '.hooks.post_run_command[0].command'
   ```
   Should show `/some/other/hook.sh`

## Backup Location

Before modifying hooks.json, a backup is created:
```
~/.codeium/windsurf/hooks.json.backup.YYYYMMDD_HHMMSS
```

To restore from backup:
```bash
cp ~/.codeium/windsurf/hooks.json.backup.* ~/.codeium/windsurf/hooks.json
```

## Troubleshooting

### hooks.json not created

Check if jq is installed:
```bash
which jq || echo "jq not found - install with: brew install jq"
```

### Permission denied

Check directory permissions:
```bash
ls -la ~/.codeium/windsurf/
```

### Hooks not working after install

1. Restart Windsurf to load new hooks
2. Check hooks.json syntax:
   ```bash
   jq . ~/.codeium/windsurf/hooks.json
   ```
3. Check notification logs:
   ```bash
   tail -f ~/.windsurf-notifier/notifications.log
   ```
