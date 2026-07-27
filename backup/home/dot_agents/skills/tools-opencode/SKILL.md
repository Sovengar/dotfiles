---
name: tools-opencode
description: >
  OpenCode itself — debugging, troubleshooting, config management, CLI reference.
  Trigger: When troubleshooting opencode, checking config, debugging issues, or managing opencode CLI/config.
triggers: [opencode, debug, troubleshooting, config, opencode-cli, opencode-debug]
---

## Debugging Entry Points

When asked to debug opencode, run **all** of these in parallel:

```bash
# 1. Resolved config — shows final merged config (global + project + managed)
opencode debug config

# 2. Global paths — shows data/config/cache/state paths
opencode debug paths

# 3. Debug info — version, platform, providers, environment
opencode debug info
```

## Debug Subcommands Reference

| Command | Purpose |
|---------|---------|
| `opencode debug config` | Show fully resolved config (merged from all sources) |
| `opencode debug paths` | Show global paths: data, config, cache, state |
| `opencode debug info` | Show version, platform, providers, env info |
| `opencode debug startup` | Print startup timing breakdown |
| `opencode debug scrap` | List all known projects |
| `opencode debug skill` | List all available skills |
| `opencode debug agent <name>` | Show agent config + optionally run a tool (`--tool`, `--params`) |
| `opencode debug lsp diagnostics <file>` | Get LSP diagnostics for a file |
| `opencode debug lsp symbols <query>` | Search workspace symbols |
| `opencode debug lsp document-symbols <uri>` | Get symbols from a document |
| `opencode debug rg tree` | Show file tree via ripgrep |
| `opencode debug rg files` | List files via ripgrep |
| `opencode debug rg search <pattern>` | Search file contents via ripgrep |
| `opencode debug file read <path>` | Read file as JSON |
| `opencode debug file status` | Show file status info |
| `opencode debug file list <path>` | List directory contents |
| `opencode debug file search <query>` | Search files by query |
| `opencode debug file tree [dir]` | Show directory tree |
| `opencode debug snapshot track` | Track current snapshot state |
| `opencode debug snapshot patch <hash>` | Show patch for snapshot |
| `opencode debug snapshot diff <hash>` | Show diff for snapshot |
| `opencode debug v2` | Debug v2 catalog and built-in plugins |
| `opencode debug wait` | Wait indefinitely (for attaching debugger) |

## Common Flags

All `opencode` commands accept:

| Flag | Purpose |
|------|---------|
| `--print-logs` | Print logs to stderr |
| `--log-level DEBUG` | Set log level (DEBUG, INFO, WARN, ERROR) |
| `--pure` | Run without external plugins |
| `--version` / `-v` | Print version number |

## Config Files & Locations

Config is **merged** from multiple sources (later overrides earlier):

| Priority | Source | Path |
|----------|--------|------|
| 1 (low) | Remote | `.well-known/opencode` (organizational) |
| 2 | Global | `~/.config/opencode/opencode.json` |
| 3 | Custom | `OPENCODE_CONFIG` env var |
| 4 | Project | `<project>/opencode.json` |
| 5 | Inline | `OPENCODE_CONFIG_CONTENT` env var |
| 6 | Managed | `/etc/opencode/` (Linux) or MDM (macOS) |
| 7 (high) | Managed prefs | macOS `.mobileconfig` via `ai.opencode.managed` |

TUI config: `~/.config/opencode/tui.json` (or `OPENCODE_TUI_CONFIG`).

## Troubleshooting Quick Reference

### Logs
```bash
# View logs (most recent 10 files kept)
ls ~/.local/share/opencode/log/
tail -f ~/.local/share/opencode/log/$(ls -t ~/.local/share/opencode/log/ | head -1)
```

### Cache / Provider Issues
```bash
# Clear provider package cache (fixes API call errors, stale packages)
rm -rf ~/.cache/opencode
```

### Storage Reset (last resort for corruption)
```bash
# ⚠️ Deletes all auth, sessions, and project data
rm -rf ~/.local/share/opencode
```

### Run Without Plugins
```bash
opencode --pure
opencode debug config --pure  # See config without plugin interference
```

### Disable Plugins Temporarily
```bash
# Edit ~/.config/opencode/opencode.json
# Set "plugin": [] then restart
```

## Useful CLI Commands

| Command | Purpose |
|---------|---------|
| `opencode models` | List available models from providers |
| `opencode models --refresh` | Refresh model cache |
| `opencode auth list` | List authenticated providers |
| `opencode auth login` | Add/configure provider credentials |
| `opencode agent list` | List all agents |
| `opencode stats` | Show token usage and cost |
| `opencode stats --days 7` | Stats for last 7 days |
| `opencode session list` | List recent sessions |
| `opencode session delete <id>` | Delete a session |
| `opencode export <sessionID>` | Export session as JSON |
| `opencode export <sessionID> --sanitize` | Export with redacted data |
| `opencode upgrade` | Upgrade to latest version |
| `opencode upgrade v0.1.48` | Upgrade to specific version |
| `opencode plugin <module>` | Install a plugin |
| `opencode db path` | Show database path |
| `opencode uninstall --dry-run` | Preview what would be removed |

## TUI vs Config — What Goes Where

OpenCode has **two separate config files** — don't mix them up:

| Config File | Path | Controls |
|-------------|------|----------|
| `opencode.json` | `~/.config/opencode/opencode.json` | Runtime: model, providers, tools, permissions, agents, MCP, LSP, formatters, shell, plugin, compaction, instructions, server |
| `tui.json` | `~/.config/opencode/tui.json` | UI only: theme, keybinds, scroll_speed, mouse, attention (notifications/sound), diff_style |

**Rule of thumb:**
- **TUI** = how it *looks and feels* (theme, keybinds, scroll speed, sounds)
- **opencode.json** = how it *behaves* (model, tools, permissions, providers, LSP, etc.)

The old way of putting `theme`, `keybinds`, and `tui` keys inside `opencode.json` is **deprecated** — they auto-migrate to `tui.json` when possible.

## Key Environment Variables

| Variable | Purpose |
|----------|---------|
| `OPENCODE_CONFIG` | Custom config file path |
| `OPENCODE_CONFIG_DIR` | Custom config directory |
| `OPENCODE_CONFIG_CONTENT` | Inline JSON config (runtime override) |
| `OPENCODE_SERVER_PASSWORD` | HTTP basic auth password for serve/web |
| `OPENCODE_SERVER_USERNAME` | HTTP basic auth username (default: opencode) |
| `OPENCODE_DISABLE_AUTOUPDATE` | Disable auto-update checks |
| `OPENCODE_DISABLE_AUTOCOMPACT` | Disable context compaction |
| `OPENCODE_DISABLE_CLAUDE_CODE` | Disable reading .claude/ files |
| `OPENCODE_ENABLE_EXPERIMENTAL` | Enable all experimental features |
| `OPENCODE_PERMISSION` | Inline JSON permissions config |
| `OPENCODE_MODELS_URL` | Custom URL for models config |

## Snapshots

Snapshots track file changes for undo/redo. Controlled via config:

```json
{ "snapshot": true }      // enabled (default)
{ "snapshot": false }     // disabled (no undo)
```

Debug: `opencode debug snapshot track` to see current snapshot state.

## Best Practices

1. **First step for any issue**: `opencode debug config` + `opencode debug info` + `opencode debug paths`
2. **Config not applying?** Check merge order — project config overrides global, managed config overrides everything
3. **Provider errors?** `opencode models --refresh` then `rm -rf ~/.cache/opencode`
4. **Plugin crashes?** Run with `--pure` to isolate, then re-enable plugins one by one
5. **Slow startup?** `opencode debug startup` pinpoints bottlenecks
