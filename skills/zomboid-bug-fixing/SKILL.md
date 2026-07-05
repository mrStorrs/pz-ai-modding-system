---
name: zomboid-bug-fixing
description: Debug and fix Project Zomboid mods from logs, crash output, and in-game failures. Use when investigating a broken mod, red context-menu options, Lua errors, missing assets, load failures, loot distribution bugs, over-spawning or under-spawning items, raw contained items appearing outside capsules/packs/wrappers, EasyDistro failures, or save-compatible fixes, especially when a mod is project-backed through a live symlink or only present as a real live folder that must be checked against Workshop before import.
---

# Zomboid Bug Fixing

Use this skill when a Project Zomboid mod is broken and you need to find the cause, fix it, and validate the result.

## Workflow

### 1. Locate the real working copy

- Prefer the project repo at `~/projects/game-mods/zomboid/<modName>`.
- If the live entry at `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/<modName>` is already a symlink, resolve it with `readlink -f` and work in that project folder.
- If the mod only exists as a real live folder, identify whether it is Workshop-backed before importing it. Do not import a Workshop-backed live folder until the Workshop-first check confirms upstream does not already contain the fix.
- Project-backed live installs are symlinks back to project folders; work in the resolved project folder, not in a copied live folder.

### 2. Read the logs first

- Inspect the relevant Project Zomboid logs before changing code.
- Start with `~/Zomboid/console.txt`, then check any related crash logs, save logs, or mod-specific output under `~/Zomboid/`.
- Look for Lua stack traces, missing files, nil accesses, bad item names, broken event hooks, and load-order problems.
- Match the log line to the mod file and code path before guessing.

### 3. Check Workshop before patching

- For existing third-party or Workshop-backed mods, inspect the local Workshop source before editing a project or live copy. Check `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`, match by `mod.info` `id=`, active version folder, and changed files, then compare it to the installed/live copy.
- If Workshop already has a compatible fix or update, prefer refreshing/replacing the live copy from Workshop instead of creating or keeping a local patch. Do not patch around a bug that upstream has already fixed.
- If Workshop does not contain the fix and the mod only exists as a real live folder, import it into `~/projects/game-mods/zomboid/<modName>`, initialize the repo and GitHub remote using the repo setup rules below, create and push an initial baseline commit of the untouched imported files unless the user explicitly asks not to commit, then do all fixes in the project repo.
- If a project-backed local copy is stale and Workshop fixes the issue, remove or replace the project-backed copy only when the user explicitly asks or approves. Otherwise, report that upstream appears fixed and identify the local drift.
- Skip the Workshop check only for clearly CJS-owned mods or mods that are not Workshop-sourced.

### Loot and spawn bugs

- If the failure concerns loot distribution, EasyDistro, spawn rates, zombie/container loot, capsules, packs, boxes, wrappers, or contained items appearing directly in loot, read and apply `/home/cjstorrs/projects/game-mods/zomboid/instructions/easy-distributions.md` before deciding on a fix.
- If that workspace instruction file is missing, continue with this skill and identify the mod's actual loot path before editing.

### Post-change review gate

- After any code, script, asset-reference, packaging, sandbox, mod-list, or live-install change, read and apply `/home/cjstorrs/projects/game-mods/zomboid/skills/zomboid-review/SKILL.md` before final closeout.
- Scope the review to the touched mod and bug domain, but do not skip it for small fixes. The review must at least cover changed files, active B42 layout, live-install drift when applicable, latest relevant logs, syntax/line-ending checks, and any domain probes that match the failure.
- If the review finds issues, apply focused fixes when they are within the user-approved bug-fix scope, rerun validation, relink the project-backed live mod if needed, and rerun the affected review checks before finishing.
- If the remaining proof requires Project Zomboid itself, state the exact in-game reproduction or log check still required.

### Repo setup and push discipline

Use these rules for Project Zomboid mod repos in `~/projects/game-mods/zomboid`.

- Keep the local mod folder name and `mod.info` `id=` stable unless the user explicitly asks to rename them.
- Local repos use `main` as the default branch. If initializing, run `git init -b main`; if a repo already exists without `main`, create `main` from `master` or current `HEAD` before the first push.
- GitHub repo names must start with `pz-` and be lowercase kebab-case from the project folder name, e.g. `cjsQuickZoom` -> `pz-cjs-quick-zoom`. Remove apostrophes, convert `&` to `and`, `+` to `plus`, split camel case and digit/letter boundaries, collapse repeated separators, and do not rename the local mod folder to match the repo.
- Create or update the GitHub repo under `mrStorrs`. Make clearly new, non-forked CJ-authored mods public only when `mod.info` or project context shows `author=CJ Storrs` and no fork/source-derived wording such as `fork`, `based on`, or `repack`; make forks, imports, third-party mods, Workshop-backed mods, helpers, and ambiguous repos private.
- After the first push of a public repo, protect `main`: set it as the default branch, disallow force pushes and deletions, and enforce protection for admins. Do not require status checks or reviews unless the repo already has that policy.
- Set `origin` to `git@github.com:mrStorrs/<repo>.git`. Push `main`, all local branches, and tags after repo creation.
- After every commit made by this skill, immediately run a normal `git push` for the committed branch. Do not force-push. If the repo has no remote yet, create/configure it with these rules first, then push.
- If GitHub hits a secondary content-creation limit while creating repos, back off and retry the same missing repo set; do not create alternate names.

### 4. Reproduce and narrow the fault

- Check `git status --short`, recent changes, and the mod layout.
- Search the mod for the log source with `rg -n` before editing.
- Reproduce the bug in the smallest path possible.
- Prefer the same patterns already used by nearby CJS mods or the upstream mod rather than inventing a new structure.

### 5. Fix the cause, not the symptom

- Keep the edit targeted.
- Preserve save compatibility unless the user explicitly accepts a breaking change.
- For Lua fixes, stay within the existing client/shared/server split.
- If the problem is a missing live link, bad folder layout, or stale live entry, fix the packaging and symlink path as part of the solution.
- Do not add defensive code unless it is an absolute must. Avoid broad nil guards, `pcall` ladders, silent skips, catch-all fallbacks, or deleting bad items/entities/save data just to prevent an error.
- If the state should be impossible, throw or log a clear targeted error with enough context to identify the source. Only guard narrowly at true trust/version boundaries such as persisted save/modData, sandbox values, client/server command payloads, optional dependencies, real Workshop/API drift, or proven nullable PZ API returns.

### 6. Validate and link

- Run `lua5.1 -e "assert(loadfile('path/to/file.lua'))"` on changed Lua files when syntax checks are possible.
- If the mod is project-backed, run `~/projects/game-mods/zomboid/link-project-mod.sh <modFolder>` before finishing so the live Zomboid mods folder has a symlink back to the project folder.
- Verify the live link is a direct child symlink under `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`, points to the project folder with matching casing, and resolves to the expected versioned `mod.info` and assets.
- Run the post-change review gate for any code, script, asset-reference, packaging, sandbox, mod-list, or live-install change.
- After validation and live linking, commit the fix in the project mod repo unless the user explicitly asked not to commit. Stage only files changed for the task, preserve unrelated user edits, push the committed branch, and leave the worktree clean when possible.
- Tell the user what still needs in-game confirmation if the behavior cannot be proven outside Project Zomboid.

## When To Stop And Ask

- Stop if the logs are missing or ambiguous enough that a guess would be risky.
- Stop if the fix would require a breaking change to save data, item IDs, or mod IDs unless the user has approved it.
- Stop if a local patch requires importing the mod into the project repo and the user has not agreed to that setup step.

## Instruction Maintenance

- If the work reveals a new recurring Project Zomboid problem, compatibility pitfall, validation pattern, or durable fix that future sessions should remember, update the relevant workspace or skill instructions while the context is fresh.
- Keep durable generic guidance in `b42.19-codex-instructions.md`; do not recreate one-off current-state notes unless the user explicitly asks.
- Keep instruction updates concise, evidence-backed, and separate from unrelated refactors or historical cleanup.
