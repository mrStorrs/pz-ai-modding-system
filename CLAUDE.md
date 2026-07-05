# Claude Code Project Documentation

## Project Overview

**Location:** `/home/cjstorrs/projects/game-mods/zomboid`

This is a Project Zomboid mod development workspace for CJS-owned mods. The project includes:
- Source code for multiple Zomboid mods in `42/` (Build 42) and `Common/` folders
- Git repositories for version control
- Integration with the live Zomboid installation at `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`

## Project Skills

These skills auto-load based on their descriptions and live in `.claude/skills/`:

- **zomboid-modding** — Project Zomboid mod creation and maintenance workflow for local B42 mods. Triggers when creating, forking, fixing, packaging, linking, or debugging mods; working in Zomboid mods directories; or troubleshooting mod discovery issues.

- **zomboid-bug-fixing** — Debug and fix Project Zomboid mods from logs, crash output, and in-game failures. Triggers when investigating broken mods, red context-menu options, Lua errors, missing assets, load failures, or save-compatible fixes.

`gabe-tailscale` (remote work on Gabriel's Linux Mint machine over Tailscale) is installed as a user-level skill at `~/.claude/skills/gabe-tailscale/`.

Most Dreamers workflow skills (`/dreamers-*`) are already available globally as slash commands in `~/.claude/commands/`.

## Project Instructions

Before adding new loot or fixing existing loot that uses Nep Easy Distributions, read and apply `.claude/instructions/easy-distributions.md`.

## Quick Reference

**Live Zomboid mods location:**
`/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`

**Project source location:**
`~/projects/game-mods/zomboid`

**CJS mod naming pattern:**
`cjs<ModName>` (e.g., `cjsQuickZoom`)

**Mod folder structure (B42):**
```
modFolder/
├── 42/
│   ├── mod.info
│   ├── poster.png
│   └── media/lua/client|shared|server/
└── Common/
```

**Key scripts:**
- `~/projects/game-mods/link-zomboid-project-mods.sh` — Reconcile project-backed live mods as symlinks without linking every project-only folder
- `~/projects/game-mods/zomboid/link-project-mod.sh <modName>` — Link one project mod as a live symlink back to this workspace

Project-backed live mods are symlinks back to this workspace. The live symlink name should match the project folder casing exactly.
