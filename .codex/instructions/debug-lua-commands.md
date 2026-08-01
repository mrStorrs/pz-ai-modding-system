# Project Zomboid B42.20 Debug Lua Commands

Use this reference when giving, running, or debugging a Lua command in the
in-game debug console or the CJS Non-Debug Lua Console.

## Traits

Build 42.20 traits use the typed `CharacterTrait` API. Do not use legacy trait
name strings or `getTraits()` for trait mutation.

```lua
-- Add Wakeful (internal ID: NeedsLessSleep) to the local player.
getPlayer():getCharacterTraits():add(CharacterTrait.NEEDS_LESS_SLEEP)

-- Check whether the local player has Wakeful.
getPlayer():hasTrait(CharacterTrait.NEEDS_LESS_SLEEP)

-- Remove Wakeful from the local player.
getPlayer():getCharacterTraits():remove(CharacterTrait.NEEDS_LESS_SLEEP)
```

Vanilla B42.20 uses the same `getCharacterTraits():add(CharacterTrait.X)`
pattern for runtime trait changes.

## Teleportation

Use `teleportTo(x, y, z)` to relocate a player. Do not use raw `setX()` and
`setY()` calls: they alter position fields without performing the full player,
square, and streaming update.

```lua
-- Single-player: replace the coordinates and floor level as needed.
getPlayer():teleportTo(10000, 10000, 0)
```

Vanilla multiplayer admin tools use the server command
`/teleportto x,y,z`; a local Lua teleport is not server-authoritative.

## Console Error Interpretation

`CJS Non-Debug Lua Console` only exposes the game's built-in debug console; it
does not rewrite the entered command. `Lua(Vanilla).console(...)` in a stack
trace is the command chunk name assigned by `UIDebugConsole`, not evidence that
the referenced vanilla Lua file caused the error. Inspect the actual nil call or
API mismatch in the entered command.
