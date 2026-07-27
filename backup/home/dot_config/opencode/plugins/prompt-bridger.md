# Prompt Bridger

Local OpenCode plugin that exposes a loopback HTTP bridge for external tools that need to append text into the active OpenCode TUI prompt.

## Files

- `prompt-bridger.ts`: OpenCode plugin loaded automatically from `~/.config/opencode/plugins/`.
- `prompt-bridger-client`: CLI client that finds the active bridge and sends text to it.
- `/tmp/opencode-prompt-bridger/<pid>.json`: runtime registry written by each OpenCode process that loads the plugin.

## Contract

- `GET /health`: returns plugin health metadata.
- `POST /append`: accepts JSON `{ "text": "..." }` and appends it to the OpenCode prompt.

The plugin formats appended text as OpenCode tracked file references:

- prefixes every unprefixed path token with `@`
- preserves tokens that already start with `@`
- treats escaped spaces (`path\ with\ spaces`) as part of the same token
- appends one trailing space so OpenCode closes the file-match popup

Example input from external tools:

```text
 agents/brainstormer.md agents/code-reviewer.md AGENTS.md
```

Text appended to OpenCode:

```text
 @agents/brainstormer.md @agents/code-reviewer.md @AGENTS.md 
```

## Client Resolution

`prompt-bridger-client` resolves the target bridge in this order:

1. `OPENCODE_PROMPT_BRIDGER_URL`
2. `OPENCODE_PROMPT_BRIDGE_URL` for already-running sessions that loaded the old plugin name
3. `OPENCODE_PID` mapped to `/tmp/opencode-prompt-bridger/<pid>.json`
4. `OPENCODE_PID` mapped to `/tmp/opencode-prompt-bridge/<pid>.json` for already-running sessions that loaded the old plugin name
5. the only registry file under those registry directories, if exactly one exists

If multiple OpenCode instances are running and no PID or URL is provided, the client refuses to guess.

## Current Producer

`fdx --floating --opencode` uses `prompt-bridger-client` on `Ctrl+O`.

`fdx` itself sends clean escaped paths. OpenCode-specific `@` formatting belongs here, in the plugin.

## Operational Notes

- OpenCode loads plugins at startup; restart OpenCode after editing `prompt-bridger.ts`.
- Keep the registry path and helper script in sync when renaming this plugin.
