

---

## New Functions — v0.2.1.11
**Generated:** 2025-09-07 12:16 (local)

| Function | File | Parameters | Description | Header Present |
|---|---|---|---|---|
| `recompute_pause_state` | `scr_utils.gml` | `` | Recomputes `global.is_paused` as `global.inv_visible || global.menu_visible`. | Yes |
| `menu_show` | `scr_utils.gml` | `` | Shows the pause menu (sets `global.menu_visible = true`) and recomputes pause. | Yes |
| `menu_hide` | `scr_utils.gml` | `` | Hides the pause menu (sets `global.menu_visible = false`) and recomputes pause. | Yes |
| `menu_toggle` | `scr_utils.gml` | `` | Toggles the pause menu visibility and recomputes pause. | Yes |


---

## Behavior Updates — v0.2.1.12
**Generated:** 2025-09-07 12:33 (local)

- `inv_show()` and `inv_hide()` now **call** `recompute_pause_state()` rather than setting `global.is_paused` directly.  
- The unified pause state is **derived** as `global.is_paused = (global.inv_visible || global.menu_visible)`.  
- Use the canonical helpers `menu_show()`, `menu_hide()`, and `menu_toggle()` instead of writing `global.menu_visible` directly (prevents desync).  
- Gameplay Step events should gate with `on_pause_exit()` which now reads `global.is_paused`.
