# Slime Game — Dependency & Usage Map Plan

**Purpose:** Define a repeatable approach to map how scripts, objects, and rooms depend on each other in *Slime Game*. This enables safer refactors, avoids duplication, and clarifies where each system is used.

---

## Scope of the Map
1. **Function Catalog:** Every globally-declared function (name, location, brief description).  
2. **Object ↔ Script Usage:** For each object event (Create/Step/Draw/Collision), list the scripts/functions it calls.  
3. **Asset References:** Sprites, tilesets, and fonts referenced by each object/script (for UI and effects).  
4. **Room Composition:** Which objects are placed/instantiated in each room and any room creation code that calls scripts.

---

## Output Artifacts (proposed)
- `docs/dependencies/functions.md` — table of functions with definitions and owning script.  
- `docs/dependencies/object-script-map.md` — object/event → called functions list.  
- `docs/dependencies/callgraph.md` — higher-level overview of subsystems and their interactions.  
- `docs/dependencies/assets.md` — assets referenced per system (UI, gameplay, environment).

> These are documentation outputs only (kept in `docs/`). Optional tooling below can help generate/maintain them.

---

## Method (Manual + Assisted)
### 1) Manual pass (initial baseline)
- For each `scripts/*.gml`, scan function definitions (`function <name>()`), copy header comments, and capture a 1–2 line description.
- For each `objects/*/*.gml` event, list obvious calls to known functions (`scr_*` or global functions).

### 2) Assisted scanning (optional tooling)
- Use a simple pattern-matcher (regex or a lightweight parser) to find `function` declarations and function calls.
- Export CSV/JSON and render Markdown tables from it.

> This can be done via a small Python script outside GameMaker, or a GML-based build step that writes text logs to `docs/`.

---

## Conventions
- **Headers:** All functions should begin with the agreed header:
  ```
  /*
  * Name:
  * Description:
  */
  ```
- **Namespacing:** Keep functions in their owning script (e.g., inventory functions in `scr_inventory.gml`).  
- **No `x`/`y` locals:** Avoid shadowing reserved variables in GameMaker code, use descriptive names (`pos_x`, `ui_origin_x`).

---

## Templates

### A) `functions.md`
| Function | File | Description | Used By (examples) |
|---|---|---|---|
| `game_init()` | `scripts/scr_globals/scr_globals.gml` | Bootstrap globals and state | `obj_game_controller.Create` |
| `inv_toggle()` | `scripts/scr_inventory/scr_inventory.gml` | Toggle inventory UI and pause | `obj_menu_controller.Step` |

### B) `object-script-map.md`
| Object | Event | Calls / Key Scripts |
|---|---|---|
| `obj_player` | Step | `pmove_*`, `dash_*`, `weapon_fire_*` |
| `obj_inventory` | Draw | `scr_draw_inventory()` |

### C) `callgraph.md` (coarse)
```
Input → Player (pmove/dash/weapon) → Bullets → Enemies
       ↘ Inventory (UI) ↔ Items
Rooms → Spawner → Enemies → Drops (Slimes) → Inventory
```

---

## Maintenance
- Update after major refactors/feature merges.
- Keep PRs that modify function signatures synced with `functions.md`.

---

**Next Step:** If approved, I can generate the initial `functions.md` and `object-script-map.md` by scanning the current repo and filling in missing descriptions from headers.
