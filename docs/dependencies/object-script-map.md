# Slime Game — Object → Script Usage Map (v0.2.1.11)

| Object | Event | Calls / Key Scripts |
|---|---|---|
| `obj_menu_controller` | `Create_0.gml` | _(no external script calls detected)_ |
| `obj_menu_controller` | `Step_0.gml` | `inv_toggle()`, `menu_toggle()` |
| `obj_menu_controller` | `Draw_64.gml` | _(no external script calls detected)_ |


---

## Verified Event Calls (obj_menu_controller) — v0.2.1.11
| Event | Calls |
|---|---|
| `Create_0.gml` | _(none from repository-defined functions)_ |
| `Step_0.gml` | `inv_toggle()`, `menu_toggle()` |
| `Draw_64.gml` | _(none — guarded to only draw when `global.menu_visible`)_ |


---

## Flow Notes (obj_menu_controller) — v0.2.1.12
- **TAB** toggles inventory **only when** no menu is visible.  
- **ESC** toggles the **pause menu in-game**; on the title screen it is ignored (or may quit if you enable that behaviour).  
- Selecting **New** or **Continue** uses `menu_hide()` (not a raw flag write) so pause/unpause stays consistent when entering `rm_game`.
