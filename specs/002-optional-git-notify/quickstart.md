# Quickstart: Optional Git Command Notifications

## What This Feature Does

Adds a configuration option to disable notifications for git commands (push, pull, fetch, clone). **Disabled by default** since most developers use passwordless Git authentication.

## Installation

If you have an existing installation, update the installed files:

```bash
./install.sh
```

Or manually copy the updated config:

```bash
cp src/config/default-config.json ~/.windsurf-notifier/config.json
```

## Configuration

### Default Behavior (git notifications disabled)

With the default config, git commands will NOT trigger notifications:

```json
{
  "enabled": true,
  "terminal_input": true,
  "git_commands": false,
  ...
}
```

### Enable Git Notifications

If you use HTTPS Git with password authentication, enable git notifications:

```bash
# Edit config
nano ~/.windsurf-notifier/config.json
```

Set `git_commands` to `true`:

```json
{
  "git_commands": true
}
```

Changes take effect immediately (no restart needed).

## Verification Tests

### Test 1: Git Notifications Disabled (Default)

1. Ensure `git_commands` is `false` in config
2. Switch to another app (Windsurf NOT focused)
3. Ask Cascade to run: `git pull`
4. **Expected**: No notification appears
5. **Check log**: `tail -1 ~/.windsurf-notifier/notifications.log`
   - Should show NO entry for git command (or SUPPRESSED if present)

### Test 2: Git Notifications Enabled

1. Set `git_commands` to `true` in config
2. Switch to another app (Windsurf NOT focused)
3. Ask Cascade to run: `git push`
4. **Expected**: Notification appears "Cascade blocked: Terminal waiting for input"
5. **Check log**: Should show SENT entry

### Test 3: Non-Git Commands Unaffected

1. With any `git_commands` setting
2. Ask Cascade to run: `sudo echo test`
3. **Expected**: Notification appears (sudo is not affected by git_commands setting)

## Troubleshooting

### Git notifications appear when I don't want them

Check your config:
```bash
cat ~/.windsurf-notifier/config.json | grep git_commands
```

Should show: `"git_commands": false`

### Config file missing git_commands

If upgrading from older version, the key may be missing. Add it manually:

```bash
# View current config
cat ~/.windsurf-notifier/config.json

# Edit and add "git_commands": false
```

Or reinstall to get the new default config:
```bash
./install.sh
```
