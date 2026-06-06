---
name: tools-snip
description: CLI that synthesizes output of verbose commands to save tokens. Load when user asks about snip.
trigger: When user asks about snip, token optimization, or output reduction
---

CLI that synthesizes output of verbose commands like git status or mvn test before sending to the agent.

## Commands

**Run command through filter:**
```powershell
snip mvn test
snip mvn clean install
snip docker build -t myapp .
snip git status
snip npm install
snip Get-ChildItem -Recurse
```

**Token savings report:**
```powershell
snip gain --daily
snip gain --weekly
snip gain --monthly
snip gain --top 10
snip gain --history 20
snip gain --quota
```

**Financial impact:**
```powershell
snip cc-economics
snip cc-economics --tier sonnet
```

**Other:**
```powershell
snip init                 # Install agent integration
snip init --agent cursor  # For specific agent
snip hook-audit           # Show recent hook activity
snip discover             # Scan for missed filter opportunities
snip verify               # Run inline filter tests
snip config               # Show current configuration
```

## Pattern

| Without snip | With snip |
|--------------|-----------|
| `mvn test` | `snip mvn test` |
| `git status` | `snip git status` |