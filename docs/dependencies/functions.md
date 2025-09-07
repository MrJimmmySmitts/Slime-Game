# Slime Game — Functions Catalog (v0.2.1)

**Generated:** 2025-09-07 07:56 (local)  
This is an initial catalog of globally-declared functions discovered in uploaded GML scripts.  
> Note: This pass includes files currently available in this workspace. Additional scripts in the repo (e.g., `scr_dash`, `scr_room_generation`, `scr_boot`) will be appended when provided.

| Function | File | Parameters | Description | Header Present |
|---|---|---|---|---|
| `cooldown_tick` | `scr_utils.gml` | `_cd` | Decrease a cooldown counter (>=0), returns updated value. | Yes |
| `vec2_normalize` | `scr_utils.gml` | `_vx, _vy` | Normalizes [vx, vy]; returns [0,0] if length is 0. | Yes |
| `on_pause_exit` | `scr_utils.gml` | `` | Returns true if game is paused and caller should skip logic. | Yes |
| `input_get_move_axis` | `scr_input.gml` | `` | Returns normalized movement vector [mx, my] from WASD keys. | Yes |
| `input_get_aim_axis` | `scr_input.gml` | `` | Returns [ax, ay, aiming] from IJKL keys (normalized if active). | Yes |
| `input_dash_pressed` | `scr_input.gml` | `` | Returns true on the frame Space is pressed. | Yes |
| `item_db_put` | `scr_items.gml` | `_id, _def` | Registers an item definition in the global DB (DS map keyed by item id). | Yes |
| `rule_make` | `scr_items.gml` | `_with_id, _result_id, _src_cost, _dst_cost, _result_count` | Convenience constructor for a single merge rule entry (A + with_id -> result). | Yes |
| `item_db_init` | `scr_items.gml` | `` | Builds the item database with stack caps and data-driven merge rules. | Yes |
| `item_get_def` | `scr_items.gml` | `_id` | Returns the item definition struct for a given id, or undefined. | Yes |
| `item_merge_rule_lookup` | `scr_items.gml` | `_a_id, _b_id` | Finds a merge rule for A+B. Checks A’s rules for B, then B’s rules for A (swapping costs). | Yes |
| `inv_can_merge` | `scr_items.gml` | `_src_stack, _dst_stack` | Returns a normalized merge rule (or undefined) for two stacks using item_merge_rule_lookup. | Yes |
| `inv_apply_merge` | `scr_items.gml` | `_src_stack, _dst_stack, _rule` | Applies a merge using a rule; returns { dst_after, src_after } or undefined if it cannot fit. | Yes |
| `inv_try_merge_drag_into_slot` | `scr_items.gml` | `_slot_index` | Attempts to merge the globally dragged stack into a given slot index. | Yes |
| `pmove_place_meeting_tilemap` | `scr_pmove.gml` | `nx, ny, col_w, col_h, tilemap` | Checks a rectangle (col_w × col_h) against a tilemap at (nx, ny). | Yes |
| `pmove_step_axis` | `scr_pmove.gml` | `dx, dy, col_w, col_h, tilemap` | Pixel-swept movement on X then Y with collision resolution. | Yes |
| `pmove_apply` | `scr_pmove.gml` | `vx, vy, speed, col_w, col_h, tilemap` | Applies normalized [vx, vy] scaled by speed with collision. | Yes |
| `weapon_fire_bullet` | `scr_weapon.gml` | `_shooter, _dx, _dy` | Spawns one bullet traveling along [dx, dy] from shooter origin. | Yes |
| `inv_panel_get_origin` | `scr_draw_inventory.gml` | `` | Return the top-left GUI position of the centred grid (used by draw/hit-test). | Yes |
| `inv_get_slot_center` | `scr_draw_inventory.gml` | `_index` | Convert slot index → GUI-space centre { xx, yy }. | Yes |
| `inv_hit_test` | `scr_draw_inventory.gml` | `` | Return slot index under the mouse in GUI space, or -1 if none. | Yes |
| `inv_draw_slots` | `scr_draw_inventory.gml` | `` | Draw slot frames (origin of slot sprite expected to be Middle-Centre). | Yes |
| `inv_draw_items` | `scr_draw_inventory.gml` | `` | Draw item stacks centred in each slot (with count in top-right). | Yes |
| `game_init` | `scr_globals.gml` | `` | Initialize all global variables and systems. Call once at game start (or from obj_inventory.Create). | Yes |
| `inv_index` | `scr_inventory.gml` | `_col, _row` | Convert (col,row) → linear slot index, or -1 if out-of-bounds. | Yes |
| `inv_can_stack` | `scr_inventory.gml` | `a, b` | True if two stacks can be merged (same id, capacity available). | Yes |
| `inv_swap` | `scr_inventory.gml` | `_i, _j` | Swap two slot indices in global.inventory_slots. | Yes |
| `inv_add` | `scr_inventory.gml` | `_id, _amount` | Add an amount of an item (enum id) into inventory. Adds as much as possible; ignores excess. | Yes |
| `world_drop_items` | `scr_inventory.gml` | `_id, _amount, _xx, _yy, _layer_name` | Spawn world pickups for a given item/amount at a position/layer (respects per-item stack sizes). | Yes |
| `inv_add_or_drop` | `scr_inventory.gml` | `_id, _amount, _xx, _yy, _layer_name` | Try to add amount of item to inventory; if not all can fit, spawn the remainder into the world. | Yes |
