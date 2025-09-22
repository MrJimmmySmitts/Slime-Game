# Object → Script Usage Map — Summary

_Last updated: 2025-09-22._

The authoritative, machine-generated cross-reference of object events and
the helper scripts they invoke lives in
[`docs/documentation/object-script-map.html`](../../docs/documentation/object-script-map.html).
Run `npm run generate-docs` after modifying object events to refresh it.

## Hierarchy Highlights

- **Gameplay controllers:** `obj_game_controller` bootstraps globals via
  `gameInit()`. `obj_menu_controller` handles pause/menu toggles.
- **Dungeon generation:** `obj_floor_gen` owns the call to
  `dgGenerateFloor()`, which now validates its configuration before
  painting tile layers.
- **Trigger family:** `obj_trigger` is the abstract base. Level exits,
  spawn markers, and enemy spawners inherit from it and share `trigger`
  helpers.
- **Enemy family:** `obj_enemy` is the parent for `obj_enemy_1`,
  `obj_enemy_2`, etc. Shared AI lives in `scr_enemy.gml` and relies on
  built-in tilemap collision helpers.
- **Pickups:** `obj_pickup_base` acts as the base class for stock and
  modifier pickups.

## Usage Tips

- When adding new descendants, set the parent object in GameMaker so they
  inherit collision events and shared create logic instead of copying
  code.
- Consult the HTML map to verify new events correctly call shared helper
  scripts; it flags events that currently have no script dependencies.
- Keep documentation consistent by regenerating the HTML map during PRs
  that touch gameplay logic.
