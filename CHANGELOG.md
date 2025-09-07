# Changelog — Slime Game

---

## [0.2.1.12] — 2025-09-07 (AEST)
### Fixed
- Pause menu displayed incorrectly when an `obj_menu_controller` instance existed in `rm_game`. Menu and inventory now coordinate via helpers and visibility flags.

### Changed
- Boot (`game_init` in `scr_boot`) now sets `menu_visible = true` for the start menu and calls `recompute_pause_state()` to derive `is_paused`.
- `inv_show()` / `inv_hide()` switched to `recompute_pause_state()`; pause is now derived from `inv_visible || menu_visible`.

### UX
- **TAB** toggles inventory only when no menu is visible.
- **ESC** toggles the pause menu in-game; on the title screen, ESC is ignored (or can be wired to quit).
- **New/Continue** actions call `menu_hide()` before loading `rm_game` to avoid lingering paused state.

### Notes
- Gameplay objects should continue to early-out in Step with `on_pause_exit()` which reads `global.is_paused`.



## [0.2.1.11] — 2025-09-07 (AEST)
### Fixed
- Pause menu drew in-game regardless of state. Menu rendering and input are now gated by `global.menu_visible`.

### Added
- New helpers in `scr_utils.gml`: `recompute_pause_state()`, `menu_show()`, `menu_hide()`, `menu_toggle()`.
- `obj_menu_controller` now uses `ESC` to toggle the pause menu (without affecting inventory), and `TAB` continues to toggle inventory.

### Notes
- Combined pause state is computed as `global.inv_visible || global.menu_visible`. Gameplay Step events should continue to gate with `on_pause_exit()`.


