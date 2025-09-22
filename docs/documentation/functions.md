# Function Reference — Curated Overview

_Last updated: 2025-09-22._

The full, auto-generated catalogue of project functions lives in
[`docs/documentation/functions.html`](functions.html). Regenerate it with
`npm run generate-docs` after modifying any script headers.

This markdown file highlights the core helpers that are most relevant to
extending the dungeon generator and related runtime systems.

## Dungeon Generation Pipeline

| Function | Location | Summary |
| --- | --- | --- |
| `dgConfigDefault()` | `scripts/scr_room_generation/scr_room_generation.gml` | Returns the baseline configuration struct. Feed it into `dgConfigValidate()` before use. |
| `dgConfigValidate(cfg)` | `scripts/scr_room_generation/scr_room_generation.gml` | Verifies numeric ranges, normalises booleans, and resolves tileset references (accepts asset ids or name strings). Emits a fatal error when misconfigured. |
| `dgConfigEnsureTilesetId(value, field)` | `scripts/scr_room_generation/scr_room_generation.gml` | Helper used by the validator and layer bootstrapper to coerce a tileset asset id from a numeric id or asset name. |
| `dgLayerRequire(name, tileset)` | `scripts/scr_room_generation/scr_room_generation.gml` | Ensures a tile layer exists, binding the correct tileset and tile dimensions using `tileset_get_tilewidth/height`. |
| `dgLayoutBuild(cfg)` | `scripts/scr_room_generation/scr_room_generation.gml` | Builds the connected NESW room graph according to the validated config. |
| `dgBuildFloorIntoRoom(cfg, graph, roomdb)` | `scripts/scr_room_generation/scr_room_generation.gml` | Creates tilemaps/layers via `dgLayerRequire()` and paints templates into them. |
| `dgGenerateFloor(cfg_override)` | `scripts/scr_room_generation/scr_room_generation.gml` | Master pipeline: merges overrides, validates config, seeds RNG, builds the layout, and paints tiles. Returns the generated graph. |

Supporting helpers include `dgConfigFail()` (consistent fatal messaging),
`dgRoomTemplateNew()`, `dgRoomdbBuildExamples()`, and `dgTilePaintRoom()`.
Consult the HTML catalogue for full parameter lists.

## Object Hierarchy Utilities

| Function | Location | Summary |
| --- | --- | --- |
| `enemyBaseInit(inst)` | `scripts/scr_enemy/scr_enemy.gml` | Shared initialiser for all enemy variants. Sets health, target acquisition, and sprite defaults. |
| `enemySeekPlayerStep(inst)` | `scripts/scr_enemy/scr_enemy.gml` | AI step shared by the enemy family (leverages parent `obj_enemy`). |
| `triggerActivate(trigger, activator)` | `scripts/scr_trigger/scr_trigger.gml` | Base trigger logic used by `obj_trigger_*` descendants. |
| `gameInit()` | `scripts/scr_boot/scr_boot.gml` | Entry point called from `obj_game_controller.Create` to construct global systems. |

## Documentation Workflow

1. Update script header blocks (Name/Description) when behaviour changes.
2. Run `npm run generate-docs` to refresh `functions.html` and the
   `object-script-map.html` cross reference.
3. Add high-level notes or architectural implications here when systems
   gain new behaviours.

This curated summary keeps documentation concise while ensuring the
machine-generated catalogue always reflects the live codebase.
